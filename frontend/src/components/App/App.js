import "./App.css";
import { useEffect, useMemo, useState } from "react";
import { initWeb3 } from "../../utils/web3";
import { useWeb3React } from "@web3-react/core";
import MyModal from "../MyModal";
import {
  Button,
  VStack,
  HStack,
  Text,
  Tooltip,
  Box,
  InputGroup,
  InputLeftElement,
  Input,
} from "@chakra-ui/react";
import { truncateAddress } from "../../utils/general";
import { CheckCircleIcon, WarningIcon } from "@chakra-ui/icons";
import ABI from "../../constants/ABI";
import Address from "../../constants/Address";

function App() {
  const [openModal, setOpenModal] = useState(false);
  const [ethAmount, setEthAmount] = useState(0);
  const [yourInfoEthAmount, setYourInfoEthAmount] = useState(0);
  const [infoEthAmount, setInfoEthAmount] = useState(0);
  const [address,setAddress] = useState("")
  const [contract, setContract] = useState();
  const { library, chainId, account, activate, deactivate, active } =
    useWeb3React();

  const closeModal = () => {
    setOpenModal(false);
  };

  const refreshState = () => {
    window.localStorage.setItem("provider", undefined);
  };

  const disconnect = () => {
    refreshState();
    deactivate();
  };

  const deposit = async () => {
    let data = await contract.methods
      .depositTokens()
      .send({ from: account, value: library.utils.toWei(ethAmount) });
    console.log(data);
  };

  const withdraw = async () => {
    let data = await contract.methods.withdrawTokens().send({ from: account });
    console.log(data);
  };

  const info = async () => {
    console.log(library);

    let data= await contract.methods.getMyBalance().call({ from: account });
    setYourInfoEthAmount(library.utils.fromWei(data))
  };

  const infoForAddress= async()=>{
    let data = await contract.methods
      .getBalance(address)
      .call({ from: account });

      setInfoEthAmount(library.utils.fromWei(data))
  }

  useEffect(() => {
    if (library) {
      const contract1 = new library.eth.Contract(ABI.abi1, Address.address1);
      setContract(contract1);
    }
  }, [library]);

  return (
    <div className="App">
      <MyModal open={openModal} handleClose={closeModal}></MyModal>
      <VStack justifyContent="center" alignItems="center" h="100vh">
        <HStack marginBottom="10px">
          <Text
            margin="0"
            lineHeight="1.15"
            fontSize={["1.5em", "2em", "3em", "4em"]}
            fontWeight="600"
          >
            Bolji tim
          </Text>
          <Text
            margin="0"
            lineHeight="1.15"
            fontSize={["1.5em", "2em", "3em", "4em"]}
            fontWeight="600"
            sx={{
              background:
                "linear-gradient(90deg, #FF0000 0%, #a1cbfb 46%,#EEEEEE 62%)",
              WebkitBackgroundClip: "text",
              WebkitTextFillColor: "transparent",
            }}
          >
            TripleM
          </Text>
        </HStack>
        <HStack>
          {!active ? (
            <Button
              onClick={() => {
                setOpenModal(true);
              }}
            >
              Connect Wallet
            </Button>
          ) : (
            <Button onClick={disconnect}>Disconnect</Button>
          )}
        </HStack>
        <VStack justifyContent="center" alignItems="center" padding="10px 0">
          <HStack>
            <Text>{`Connection Status: `}</Text>
            {active ? (
              <CheckCircleIcon color="green" />
            ) : (
              <WarningIcon color="#cd5700" />
            )}
          </HStack>

          <Tooltip label={account} placement="right">
            <Text>{`Account: ${truncateAddress(account)}`}</Text>
          </Tooltip>
          <Text>{`Network ID: ${chainId ? chainId : "No Network"}`}</Text>
        </VStack>
        {active && (
          <HStack justifyContent="flex-start" alignItems="flex-start">
            <Box
              maxW="sm"
              borderWidth="1px"
              borderRadius="lg"
              overflow="hidden"
              padding="10px"
            >
              <VStack>
                <Text
                  margin="0"
                  lineHeight="1.15"
                  fontSize={["0.5em", "1.5em", "1.5em", "1.5em"]}
                  fontWeight="600"
                  sx={{
                    background:
                      "linear-gradient(45deg, #000000 0%,#EEEEEE 100%)",
                    WebkitBackgroundClip: "text",
                    WebkitTextFillColor: "transparent",
                  }}
                >
                  Deposit/Withdraw
                </Text>
                <HStack>
                  <InputGroup>
                    <InputLeftElement
                      pointerEvents="none"
                      color="gray.300"
                      fontSize="1.2em"
                      children="ETH"
                    />
                    <Input
                      placeholder="Enter amount"
                      type="number"
                      value={ethAmount}
                      onChange={(e) => {
                        setEthAmount(e.target.value);
                      }}
                    />
                  </InputGroup>
                  <Button onClick={deposit}>Deposit</Button>
                </HStack>
                <Button onClick={withdraw}>Withdraw</Button>
              </VStack>
            </Box>
            <Box
              maxW="sm"
              borderWidth="1px"
              borderRadius="lg"
              overflow="hidden"
              padding="10px"
            >
              <VStack>
                <Text
                  margin="0"
                  lineHeight="1.15"
                  fontSize={["0.5em", "1.5em", "1.5em", "1.5em"]}
                  fontWeight="600"
                  sx={{
                    background:
                      "linear-gradient(45deg, #000000 0%,#EEEEEE 100%)",
                    WebkitBackgroundClip: "text",
                    WebkitTextFillColor: "transparent",
                  }}
                >
                  Get info for your address
                </Text>
                <Button onClick={info}>Info</Button>
                <Text>
                  {yourInfoEthAmount} ETH
                </Text>
              </VStack>
            </Box>
            <Box
              maxW="sm"
              borderWidth="1px"
              borderRadius="lg"
              overflow="hidden"
              padding="10px"
            >
              <VStack>
                <Text
                  margin="0"
                  lineHeight="1.15"
                  fontSize={["0.5em", "1.5em", "1.5em", "1.5em"]}
                  fontWeight="600"
                  sx={{
                    background:
                      "linear-gradient(45deg, #000000 0%,#EEEEEE 100%)",
                    WebkitBackgroundClip: "text",
                    WebkitTextFillColor: "transparent",
                  }}
                >
                  Get info for address
                </Text>
                <HStack>
                  <InputGroup>
                    <Input
                      placeholder="Enter address"
                      value={address}
                      onChange={(e) => {
                        setAddress(e.target.value);
                      }}
                    />
                  </InputGroup>
                  <Button onClick={infoForAddress}>Info</Button>
                </HStack>
                <Text>
                  {infoEthAmount} ETH
                </Text>
              </VStack>
            </Box>
          </HStack>
        )}
      </VStack>
    </div>
  );
}

export default App;
