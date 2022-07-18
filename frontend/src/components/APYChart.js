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
    let inter=1000
    const interval = setInterval(() => {
      axios
        .get(process.env.REACT_APP_API+"apy")
        .then((response) => {
          let apysTemp = [];
          response.data.forEach((d) => {
            let a = new Date(d.timestamp * 1000);
            let months = [
              "Jan",
              "Feb",
              "Mar",
              "Apr",
              "May",
              "Jun",
              "Jul",
              "Aug",
              "Sep",
              "Oct",
              "Nov",
              "Dec",
            ];
            let year = a.getFullYear();
            let month = months[a.getMonth()];
            let date = a.getDate();
            let hour = a.getHours();
            let min = a.getMinutes();
            let sec = a.getSeconds();
            let time =
              date +
              " " +
              month +
              " " +
              year +
              " " +
              hour +
              ":" +
              min +
              ":" +
              sec;
            apysTemp.push({
              depositAPY: d.depositAPY,
              timestamp: time,
            });
          });
          setApys(apysTemp);
        });
        inter=10000
    }, inter);
    return () => clearInterval(interval);
  }, []);

  return (
    <LineChart
      width={1000}
      height={250}
      data={apys}
      margin={{ top: 5, right: 20, bottom: 5, left: 0 }}
    >
      <Line type="monotone" dataKey="depositAPY" stroke="#8884d8" />
      <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
      <XAxis dataKey="timestamp" />
      <YAxis />
      <Tooltip />
    </LineChart>
  );
}
