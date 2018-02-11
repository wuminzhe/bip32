defmodule Bip32.Node do
  defstruct [:private_key, :public_key, :chain_code, :depth, :index, :parent]

  # https://bitcoin.org/img/dev/en-hd-root-keys.svg
  def generate_master_node(seed_hex) do
    # hash the seed
    seed = Bip32.Utils.pack_h(seed_hex)
    one_way_hash = Bip32.Utils.hmac_sha512("Bitcoin seed", seed)

    # get the private key and chain code
    master_private_key_hex  = String.slice(one_way_hash, 0..63) # left is the private key
    master_chain_code_hex = String.slice(one_way_hash, 64..127) # right is the chain code

    # get the master public key from master private key
    master_public_key_hex = Bip32.Utils.get_public_key_from_private_key(master_private_key_hex)

    %Bip32.Node{
      private_key: master_private_key_hex, 
      public_key: master_public_key_hex, 
      chain_code: master_chain_code_hex,
      depth: 0,
      index: 0
    }
  end

  def to_bip32(node, network \\ "mainnet") do
    version_prv = if network == "mainnet", do: "0488ade4", else: "04358394"
    version_pub = if network == "mainnet", do: "0488b21e", else: "043587cf"
    depth = node.depth |> Integer.to_string(16) |> String.pad_leading(2, "0") |> String.downcase
    parent_key_fingerprint = ( if node.depth == 0, do: "00000000", else: Bip32.Utils.fingerprint(node.parent.public_key) )
    child_number = node.index |> Integer.to_string(16) |> String.pad_leading(8, "0") |> String.downcase

    xprv =
      case node.private_key do
        nil -> nil
        _ -> serialize(version_prv, depth, parent_key_fingerprint, child_number, node.chain_code, "00#{node.private_key}")
      end
    xpub = serialize(version_pub, depth, parent_key_fingerprint, child_number, node.chain_code, node.public_key)

    if xprv == nil do
      %{xpub: Bip32.Utils.checksum_base58(xpub)}
    else
      %{xpub: Bip32.Utils.checksum_base58(xpub), xprv: Bip32.Utils.checksum_base58(xprv)}
    end
    
  end

  def from_bip32(bip32) do
    decoded = "0" <> (Base58.decode(bip32) |> Integer.to_string(16))
    checksum = String.slice(decoded, -8..-1)
    bip32 = String.slice(decoded, 0..-9) |> String.downcase

    version = String.slice(bip32, 0..7)
    depth = String.slice(bip32, 8..9)
    parent_key_fingerprint = String.slice(bip32, 10..17)
    child_number = String.slice(bip32, 18..25)
    chain_code = String.slice(bip32, 26..89)
    key = String.slice(bip32, 90..-1)

    if String.slice(key, 0..1) == "00" do
      private_key = String.slice(key, 2..-1)
      public_key  = Bip32.Utils.get_public_key_from_private_key(private_key)
    else
      private_key = nil
      public_key  = key
    end

    %Bip32.Node{
      private_key: private_key, 
      public_key: public_key, 
      chain_code: chain_code,
      depth: String.to_integer(depth, 16),
      index: String.to_integer(child_number, 16)
    }
  end

  defp serialize(version, depth, parent_key_fingerprint, child_number, chain_code, key_hex) do
    version <> depth <> parent_key_fingerprint <> child_number <> chain_code <> key_hex
  end

  @order String.to_integer("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", 16)

  # https://bitcoin.org/img/dev/en-hd-private-parent-to-private-child.svg
  def derive_child(node, i \\ 0) do
    # generate the "one way hash"
    if i >= 0x80000000 do # hardened. it impossible to create child public keys without knowing the parent private key
      message = <<0>> <> Bip32.Utils.pack_h(node.private_key) <> Bip32.Utils.i_as_bytes(i)
      one_way_hash = Bip32.Utils.pack_h(node.chain_code) |> Bip32.Utils.hmac_sha512(message)
    else # normal.
      message = Bip32.Utils.pack_h(node.public_key) <> Bip32.Utils.i_as_bytes(i)
      one_way_hash = Bip32.Utils.pack_h(node.chain_code) |> Bip32.Utils.hmac_sha512(message)
    end

    # get the child private key
    left_int = one_way_hash |> String.slice(0..63) |> String.to_integer(16)
    child_private_key = rem (left_int + String.to_integer(node.private_key, 16)), @order
    child_private_key_hex = child_private_key |> Integer.to_string(16) |> String.downcase |> String.pad_leading(64, "0")

    # get the child chain code
    child_chain_code = one_way_hash |> String.slice(64..127) |> String.to_integer(16)
    child_chain_code_hex = child_chain_code |> Integer.to_string(16) |> String.downcase |> String.pad_leading(64, "0")

    # get the child public key
    child_public_key_hex = Bip32.Utils.get_public_key_from_private_key(child_private_key_hex)

    %Bip32.Node{
      private_key: child_private_key_hex, 
      public_key: child_public_key_hex, 
      chain_code: child_chain_code_hex,
      depth: node.depth + 1,
      index: i,
      parent: node
    }
  end

  def path(node) do
    
  end

end