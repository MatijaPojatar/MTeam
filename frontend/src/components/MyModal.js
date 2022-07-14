import React from "react";
import {
  VStack,
  HStack,
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalBody,
  ModalCloseButton,
  Button,
  Text
} from "@chakra-ui/react";
import { Image } from "@chakra-ui/react";
import { useWeb3React } from "@web3-react/core";
import { connectors } from "../utils/connectors";

const style = {
  position: "absolute",
  top: "50%",
  left: "50%",
  transform: "translate(-50%, -50%)",
  width: 400,
  bgcolor: "background.paper",
  border: "2px solid #000",
  boxShadow: 24,
  p: 4,
};

export default function MyModal({ open, handleClose }) {
  const { activate } = useWeb3React();

  const setProvider = (type) => {
    window.localStorage.setItem("provider", type);
  };
  return (
    <Modal isOpen={open} onClose={handleClose} isCentered>
      <ModalOverlay />
      <ModalContent w="300px">
        <ModalHeader>Select Wallet</ModalHeader>
        <ModalCloseButton
          _focus={{
            boxShadow: "none"
          }}
        />
        <ModalBody paddingBottom="1.5rem">
          <VStack>
            <Button
              variant="outline"
              onClick={() => {
                activate(connectors.walletConnect);
                setProvider("walletConnect");
                handleClose();
              }}
              w="100%"
            >
              <HStack w="100%" justifyContent="center">
                <Image
                  src="wc.png"
                  alt=""
                  width={26}
                  height={26}
                  borderRadius="3px"
                />
                <Text>Wallet Connect</Text>
              </HStack>
            </Button>
            <Button
              variant="outline"
              onClick={() => {
                activate(connectors.injected);
                setProvider("injected");
                handleClose();
              }}
              w="100%"
            >
              <HStack w="100%" justifyContent="center">
                <Image
                  src="mm.png"
                  alt=""
                  width={25}
                  height={25}
                  borderRadius="3px"
                />
                <Text>Metamask</Text>
              </HStack>
            </Button>
          </VStack>
        </ModalBody>
      </ModalContent>
    </Modal>
  );
}
