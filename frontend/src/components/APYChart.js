import React, { useEffect, useState } from "react";
import {
  LineChart,
  Line,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
} from "recharts";
import axios from "axios";

export default function APYChart() {
  const data = [
    { name: "01/01/2022", APY: 3.2 },
    { name: "02/01/2022", APY: 6.2 },
    { name: "03/01/2022", APY: 5.2 },
    { name: "04/01/2022", APY: 6.5 },
    { name: "05/01/2022", APY: 2.8 },
  ];

  const [apys, setApys] = useState([]);

  useEffect(() => {
    const interval = setInterval(() => {
      axios
        .get("https://18ed-80-93-248-90.eu.ngrok.io/apy")
        .then((response) => {
          console.log(response.data);
          setApys(response.data);
        });
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  return (
    <LineChart
      width={1000}
      height={250}
      data={data}
      margin={{ top: 5, right: 20, bottom: 5, left: 0 }}
    >
      <Line type="monotone" dataKey="APY" stroke="#8884d8" />
      <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
      <XAxis dataKey="name" />
      <YAxis />
      <Tooltip />
    </LineChart>
  );
}
