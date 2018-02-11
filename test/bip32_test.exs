defmodule Bip32Test do
  use ExUnit.Case
  doctest Bip32

  test "generete master node from hex seed" do
    node = Bip32.Node.generate_master_node("6411fc4e712edf19a06bc5")

    assert node.private_key == "019501a2dcd7b5450388df7e3b426a5422c3570425296f206fecee56f332c079"
    assert node.public_key  == "02962f81719ca3de1c431c15af996bb9558b1790d8031cbfe702276fb754d44d33"
    assert node.chain_code  == "a386d620fc62c7a6a4ed83a19a0638c54c1486d8d8a60bfeeacac1b7a2e2e911"
    assert node.depth       == 0
    assert node.index       == 0
  end

  test "to bip32" do
    node = Bip32.Node.generate_master_node("6411fc4e712edf19a06bc5")

    bip32 = Bip32.Node.to_bip32(node)
    assert bip32.xprv == "xprv9s21ZrQH143K3gnXBZCcM9RAqTSzcEn6jK321gwpdN5XYR9i8m7WhRyuWTHgoNJDjVq9TgCQHgs5j875ZCPXVTrpkQwzdtTPUDPitoxJ4t5"
    assert bip32.xpub == "xpub661MyMwAqRbcGArzHajciHMuPVHV1hVx6Xxcp5MSBhcWRDUrgJRmFEJPMjSu7tXdzwvxrFojYP8oYne1X9Y4xWgyfWD3thLxpa3NEnPsMG8"
  end

  test "from bip32 xprv" do
    bip32 = "xprv9s21ZrQH143K3gnXBZCcM9RAqTSzcEn6jK321gwpdN5XYR9i8m7WhRyuWTHgoNJDjVq9TgCQHgs5j875ZCPXVTrpkQwzdtTPUDPitoxJ4t5"
    node = Bip32.Node.from_bip32(bip32)

    assert node.private_key == "019501a2dcd7b5450388df7e3b426a5422c3570425296f206fecee56f332c079"
    assert node.public_key  == "02962f81719ca3de1c431c15af996bb9558b1790d8031cbfe702276fb754d44d33"
    assert node.chain_code  == "a386d620fc62c7a6a4ed83a19a0638c54c1486d8d8a60bfeeacac1b7a2e2e911"
    assert node.depth       == 0
    assert node.index       == 0
  end

  test "from bip32 xpub" do
    bip32 = "xpub661MyMwAqRbcGArzHajciHMuPVHV1hVx6Xxcp5MSBhcWRDUrgJRmFEJPMjSu7tXdzwvxrFojYP8oYne1X9Y4xWgyfWD3thLxpa3NEnPsMG8"
    node = Bip32.Node.from_bip32(bip32)

    assert node.private_key == nil
    assert node.public_key  == "02962f81719ca3de1c431c15af996bb9558b1790d8031cbfe702276fb754d44d33"
    assert node.chain_code  == "a386d620fc62c7a6a4ed83a19a0638c54c1486d8d8a60bfeeacac1b7a2e2e911"
    assert node.depth       == 0
    assert node.index       == 0
  end

  test "derive child" do
    node = Bip32.Node.generate_master_node("6411fc4e712edf19a06bc5")
    child_node = Bip32.Node.derive_child(node, 5)

    assert child_node.private_key == "4ff08af436785a6de1bdea489342a84a0c6d79caef43140375c1ef220c29bc4c"
    assert child_node.public_key  == "0207ad96a500055f694c57637897018e771e25af129ad89aacc1b7ea900fb232a1"
    assert child_node.chain_code  == "5408be244f01d7ba9900b9d65159e011c128cf067f3281a65e61ca1fb7f5edb2"
    assert child_node.depth       == 1
    assert child_node.index       == 5
  end
end
