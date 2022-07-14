import React from "react";
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

export default function LogTable() {
  const logs = [
    {
      action: "Deposit",
      value: 0.01,
      timestamp: "01/01/2022",
    },
    {
      action: "Withdraw",
      value: 0.007,
      timestamp: "01/01/2022",
    },
    {
      action: "Deposit",
      value: 0.01,
      timestamp: "01/01/2022",
    },
  ];
  return (
    <TableContainer>
      <Table variant="simple">
        <TableCaption>Logs</TableCaption>
        <Thead>
          <Tr>
            <Th>Action</Th>
            <Th isNumeric>Value</Th>
            <Th>Timestamp</Th>
          </Tr>
        </Thead>
        <Tbody>
          {logs.map((l) => (
            <Tr>
                <Td>{l.action}</Td>
                <Td>{l.value} ETH</Td>
                <Td>{l.timestamp}</Td>
            </Tr>
          ))}
        </Tbody>
      </Table>
    </TableContainer>
  );
}
