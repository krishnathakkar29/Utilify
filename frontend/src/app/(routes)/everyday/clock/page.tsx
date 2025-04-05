"use client";

import React, { useState, useEffect } from "react";
import { BACKEND_FLASK_URL } from "@/config/config";
const unitConversions: Record<string, string[]> = {
  length: ["mm", "cm", "m", "km", "in", "ft", "yd", "mi"],
  weight: ["kg", "g", "mg", "ton", "lb", "oz"],
  volume: ["l", "ml", "m3", "gal", "qt", "pt", "cup", "floz"],
  temp: ["C", "F", "K"],
};

const currencyOptions = [
    'Afganistan', 'Albania', 'Alergia', 'American Samoa', 'Andorra', 'Angola',
    'Anguilla', 'Antigua and Barbuda', 'Argentina', 'Armenia', 'Aruba', 'Australia',
    'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados',
    'Belarus', 'Belgium', 'Belize', 'Benin', 'Bermuda', 'Bhutan', 'Bolivia',
    'Bonaire', 'Boznia and herzegovina', 'Botswana', 'Bouvet', 'Brazil',
    'British Indian Ocean Terriotory', 'Brunei Daraussalam', 'Bulgaria', 'Burkina',
    'Burundi', 'Cape Verde', 'Cambodia', 'Cameroon', 'Canada', 'Cayman Islands',
    'Central African Repulic', 'Chad', 'Chile', 'China', 'Christmas Island',
    'Cocos Islands', 'Colombia', 'Comoros', 'The Democratic Repulic of Congo',
    'The Cook Islands', 'Costa Rica', 'Croatia', 'Cuba', 'CuraÇao', 'Cyprus',
    'Czech Repulic', 'Ivory Coast', 'Denmark', 'Djibouti', 'Dominica',
    'The Dominican Republic', 'Equador', 'Egypt', 'El Salvador',
    'Equatorial Guniea', 'Eritrea', 'Estonia', 'Ethipia', 'The Falkland',
    'The Faroe', 'Fiji', 'Finland', 'France', 'French Guiana', 'French Polynesia',
    'French Southern Territores', 'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana',
    'Gibraltar', 'Greece', 'Greenland', 'Grenada', 'Guadeloupe', 'Guam',
    'Guatemala', 'Guernsey', 'Guniea', 'Guinea-Bisaau', 'Guyana', 'Haiti',
    'Holy See', 'Honduras', 'Hong Kong', 'Hungary', 'Iceland', 'India',
    'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Isle of man', 'Israel', 'Italy',
    'Jamaica', 'Japan', 'Jersey', 'Jordan', 'Kazakstan', 'Kenya', 'Kiribati',
    'North Korea', 'South Korea', 'Kuwait', 'Kyrgyzstan', 'Lao', 'Latvia',
    'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Liechensteain', 'Lithuania',
    'Luxembourg', 'Macao', 'Madagascar', 'Malawi', 'Malaysia', 'Maldives', 'Mali',
    'Malta', 'The Marshall Islands', 'Martinque', 'Mauritania', 'Mauritius',
    'Mayotte', 'Mexico', 'Micronesia', 'Moldova', 'Monaco', 'Mongolia',
    'Montenegro', 'Montserrat', 'Morocco', 'Mozambique', 'Myanmar', 'Namibia',
    'Nauru', 'Nepal', 'The Netherlands', 'New Caledonia', 'New Zealand',
    'Nicaragua', 'Niger', 'Nigeria', 'Niue', 'Nolfolf Island',
    'Northern Mariana Islands', 'Norway', 'Oman', 'Pakistan', 'Palau', 'Panama',
    'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Pitcairn', 'Poland',
    'Portugal', 'Puerto Rico', 'Qatar', 'North Macedonia', 'Romania', 'Russia',
    'Rwanda', 'Réunion', 'Saint Barts', 'Saint Helena', 'Saint Kitts and Nevis',
    'Saint Lucia', 'Saint Martin', 'Saint Pierre and Miquelon',
    'Saint Vincent and the Grenadines', 'Samoa', 'San Marino',
    'Sao Tome and Principe', 'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles',
    'Sierra Leone', 'Singapore', 'Sint Maarten', 'Slovakia', 'Slovenia',
    'Solomon Islands', 'Somalia', 'South Africa', 'South Sudan', 'Spain',
    'Sri Lanka', 'Sudan', 'Suriname', 'Svalbard and Jan Mayen', 'Swaziland',
    'Sweden', 'Switzerland', 'Syria', 'Taiwan', 'Tajikistan', 'Tanzania',
    'Thailand', 'Timor-leste', 'Togo', 'Tokelau', 'Tonga',
    'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan',
    'Turks and Caicos Islands', 'Tuvalu', 'Uganda', 'Ukraine',
    'United Arab Emirates', 'United Kingdom', 'United States Minor Outlying Islands',
    'United States of America', 'Uruguay', 'Uzbekistan', 'Vanuatu', 'Venezuela',
    'Vietnam', 'British Virgin Islands', 'US Virgin Islands', 'Wallis and Futuna',
    'Western Sahara', 'Yemen', 'Zambia', 'Zimbabwe', 'Åland Islands'
]
;

const Page: React.FC = () => {
  const [conversionType, setConversionType] = useState<string>("length");
  const [fromUnit, setFromUnit] = useState<string>("");
  const [toUnit, setToUnit] = useState<string>("");
  const [value, setValue] = useState<string>("");
  const [convertedValue, setConvertedValue] = useState<string>("");

  const [fromCurrency, setFromCurrency] = useState<string>("USD");
  const [toCurrency, setToCurrency] = useState<string>("EUR");
  const [amount, setAmount] = useState<string>("");
  const [convertedCurrency, setConvertedCurrency] = useState<string>("");

  const [timer, setTimer] = useState<number>(0);
  const [running, setRunning] = useState<boolean>(false);

  const [count, setCount] = useState<number>(0);

  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (running) {
      interval = setInterval(() => {
        setTimer((prev) => prev + 1);
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [running]);

  const handleUnitConvert = async () => {
    if (!value || !fromUnit || !toUnit) return;
    try {
        const response = await fetch(`${BACKEND_FLASK_URL}/convert_${conversionType}`, {
            method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          value: parseFloat(value),
          from_unit: fromUnit,
          to_unit: toUnit,
        }),
      });

      const data = await response.json();
      setConvertedValue(`${data.result} ${data.unit}`);
    } catch (error) {
      console.error("Conversion error:", error);
      setConvertedValue("Error");
    }
  };

  const handleCurrencyConvert = async () => {
    if (!amount || !fromCurrency || !toCurrency) return;
  
    try {
      const response = await fetch(`${BACKEND_FLASK_URL}/convert_currency`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          from: fromCurrency,
          to: toCurrency,
          amount: parseFloat(amount),
        }),
      });
  
      const data = await response.json();
  
      if (data.converted) {
        setConvertedCurrency(`${data.converted} ${data.to_code}`);
      } else {
        setConvertedCurrency("Error converting currency");
      }
    } catch (error) {
      console.error("Currency conversion error:", error);
      setConvertedCurrency("Error");
    }
  };
  

  return (
    <div className="p-6 text-white bg-gray-900 min-h-screen space-y-10">
      <h1 className="text-3xl font-bold">Work</h1>

      {/* Unit Converter */}
      <div className="space-y-4 bg-gray-800 p-4 rounded-xl shadow-lg">
        <h2 className="text-xl font-semibold">Unit Converter</h2>

        <label className="block">Conversion Type:</label>
        <select
          value={conversionType}
          onChange={(e) => {
            setConversionType(e.target.value);
            setFromUnit("");
            setToUnit("");
          }}
          className="bg-gray-700 text-white p-2 rounded w-full"
        >
          {Object.keys(unitConversions).map((type) => (
            <option key={type} value={type}>
              {type}
            </option>
          ))}
        </select>

        <div className="flex flex-col md:flex-row gap-2">
          <div className="w-full">
            <label className="block">From Unit:</label>
            <select
              value={fromUnit}
              onChange={(e) => setFromUnit(e.target.value)}
              className="bg-gray-700 text-white p-2 rounded w-full"
            >
              <option value="">Select</option>
              {unitConversions[conversionType].map((unit) => (
                <option key={unit} value={unit}>
                  {unit}
                </option>
              ))}
            </select>
          </div>

          <div className="w-full">
            <label className="block">To Unit:</label>
            <select
              value={toUnit}
              onChange={(e) => setToUnit(e.target.value)}
              className="bg-gray-700 text-white p-2 rounded w-full"
            >
              <option value="">Select</option>
              {unitConversions[conversionType].map((unit) => (
                <option key={unit} value={unit}>
                  {unit}
                </option>
              ))}
            </select>
          </div>
        </div>

        <label className="block">Value:</label>
        <input
          type="number"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          placeholder="Enter value"
          className="bg-gray-700 text-white placeholder-white p-2 rounded w-full"
        />
        <button
          onClick={handleUnitConvert}
          className="bg-blue-600 px-4 py-2 rounded hover:bg-blue-500"
        >
          Convert
        </button>
        {convertedValue && (
          <p className="mt-2 text-green-400">Converted: {convertedValue}</p>
        )}
      </div>

      {/* Currency Converter */}
      <div className="space-y-4 bg-gray-800 p-4 rounded-xl shadow-lg">
        <h2 className="text-xl font-semibold">Currency Converter</h2>

        <div className="flex flex-col md:flex-row gap-2">
          <div className="w-full">
            <label className="block">From Currency:</label>
            <select
              value={fromCurrency}
              onChange={(e) => setFromCurrency(e.target.value)}
              className="bg-gray-700 text-white p-2 rounded w-full"
            >
              {currencyOptions.map((cur) => (
                <option key={cur} value={cur}>
                  {cur}
                </option>
              ))}
            </select>
          </div>

          <div className="w-full">
            <label className="block">To Currency:</label>
            <select
              value={toCurrency}
              onChange={(e) => setToCurrency(e.target.value)}
              className="bg-gray-700 text-white p-2 rounded w-full"
            >
              {currencyOptions.map((cur) => (
                <option key={cur} value={cur}>
                  {cur}
                </option>
              ))}
            </select>
          </div>
        </div>

        <label className="block">Amount:</label>
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="Enter amount"
          className="bg-gray-700 text-white placeholder-white p-2 rounded w-full"
        />
        <button
          onClick={handleCurrencyConvert}
          className="bg-green-600 px-4 py-2 rounded hover:bg-green-500"
        >
          Convert
        </button>
        {convertedCurrency && (
          <p className="mt-2 text-yellow-400">Converted: {convertedCurrency}</p>
        )}
      </div>

      {/* Timer */}
      <div className="space-y-4 bg-gray-800 p-4 rounded-xl shadow-lg">
        <h2 className="text-xl font-semibold">Timer</h2>
        <p className="text-2xl">{timer}s</p>
        <div className="flex gap-2">
          <button
            onClick={() => setRunning(!running)}
            className="bg-purple-600 px-4 py-2 rounded hover:bg-purple-500"
          >
            {running ? "Stop" : "Start"}
          </button>
          <button
            onClick={() => {
              setTimer(0);
              setRunning(false);
            }}
            className="bg-gray-600 px-4 py-2 rounded hover:bg-gray-500"
          >
            Reset
          </button>
        </div>
      </div>

      {/* Counter */}
      <div className="space-y-4 bg-gray-800 p-4 rounded-xl shadow-lg">
        <h2 className="text-xl font-semibold">Counter</h2>
        <p className="text-2xl">{count}</p>
        <div className="flex gap-2">
          <button
            onClick={() => setCount(count + 1)}
            className="bg-teal-600 px-4 py-2 rounded hover:bg-teal-500"
          >
            Increment
          </button>
          <button
            onClick={() => setCount(count - 1)}
            className="bg-red-600 px-4 py-2 rounded hover:bg-red-500"
          >
            Decrement
          </button>
          <button
            onClick={() => setCount(0)}
            className="bg-gray-600 px-4 py-2 rounded hover:bg-gray-500"
          >
            Reset
          </button>
        </div>
      </div>
    </div>
  );
};

export default Page;
