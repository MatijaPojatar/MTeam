import "./App.css";
import { useEffect, useMemo, useState } from "react";
import { initWeb3 } from "../../utils/web3";
import { useWeb3React } from "@web3-react/core";
import MyModal from "../MyModal";
import { Button, VStack, HStack, Text, Tooltip, Box,InputGroup,InputLeftElement,Input } from "@chakra-ui/react";
import { truncateAddress } from "../../utils/general";
import { CheckCircleIcon, WarningIcon } from "@chakra-ui/icons";

function App() {
  const [cdpData, setCdpData] = useState();
  const [id, setId] = useState(0);
  const [userAccount, setUserAccount] = useState();
  const [openModal, setOpenModal] = useState(false);
  const [signature, setSignature] = useState("");
  const [error, setError] = useState("");
  const [network, setNetwork] = useState(undefined);
  const [message, setMessage] = useState("");
  const [signedMessage, setSignedMessage] = useState("");
  const [verified, setVerified] = useState();
  const { library, chainId, account, activate, deactivate, active } =
    useWeb3React();

  const web3 = useMemo(() => initWeb3(), []);

  const closeModal = () => {
    setOpenModal(false);
  };

  const refreshState = () => {
    window.localStorage.setItem("provider", undefined);
    setNetwork("");
    setMessage("");
    setSignature("");
    setVerified(undefined);
  };

  const disconnect = () => {
    refreshState();
    deactivate();
  };

  const deposit = () => {};

  const withdraw = () => {};

  useEffect(() => {}, []);

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
                <HStack>
                  <InputGroup>
                    <InputLeftElement
                      pointerEvents="none"
                      color="gray.300"
                      fontSize="1.2em"
                      children="ETH"
                    />
                    <Input placeholder="Enter amount" />
                  </InputGroup>
                  <Button onClick={deposit}>Deposit</Button>
                </HStack>
                <Button onClick={withdraw}>Withdraw</Button>
              </VStack>
            </Box>
          </HStack>
        )}
      </VStack>
    </div>
  );
}

export default App;
