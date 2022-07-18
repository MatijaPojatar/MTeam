import React, { useEffect, useState } from "react";
import axios from "axios";
import {
  TableContainer,
  Table,
  TableCaption,
  Tr,
  Th,
  Tbody,
  Thead,
  Td,
  Tfoot,
} from "@chakra-ui/react";
import { useWeb3React } from "@web3-react/core";

export default function LogTable() {
  const [logs, setLogs] = useState([]);
  const { library, chainId, account, activate, deactivate, active } =
    useWeb3React();

  function compare(a, b) {
    if (a.blockNumber < b.blockNumber) {
      return -1;
    }
    if (a.blockNumber > b.blockNumber) {
      return 1;
    }
    return 0;
  }

  useEffect(() => {
    let inter = 1000;
    const interval = setInterval(() => {
      axios.get(process.env.REACT_APP_API + "events").then((response) => {
        let logsTemp = [];
        response.data.forEach((element) => {
          logsTemp.push({
            id: element.event_id,
            blockNumber: element.blockNumber,
            value: element.withdraw
              ? library.utils.fromWei(String(element.withdraw))
              : library.utils.fromWei(String(element.deposit)),
            action: element.withdraw ? "Withdraw" : "Deposit",
            address: element.address,
          });
        });
        logsTemp.sort( compare );
        setLogs(logsTemp);
      });
      inter = 10000;
    }, inter);
    return () => clearInterval(interval);
  }, []);

  return (
    <TableContainer>
      <Table variant="simple">
        <TableCaption>Logs</TableCaption>
        <Thead>
          <Tr>
            <Th>Address</Th>
            <Th>Action</Th>
            <Th isNumeric>Value</Th>
            <Th>Block number</Th>
          </Tr>
        </Thead>
        <Tbody>
          {logs.map((l) => (
            <Tr id={l.id}>
              <Td>{l.address}</Td>
              <Td>{l.action}</Td>
              <Td>{l.value} ETH</Td>
              <Td>{l.blockNumber}</Td>
            </Tr>
          ))}
        </Tbody>
      </Table>
    </TableContainer>
  );
}
