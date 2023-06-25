// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TraitTestFullContract is ERC721, Ownable {
    using EnumerableSet for EnumerableSet.UintSet;

    error PreSaleNotActive();
    error PublicSaleNotActive();
    error NoContracts();

    mapping(uint256 => EnumerableSet.UintSet) private traitToTokenIds;
    mapping(uint256 => bool) public mintedTokens;
    uint256[] public availableTokenIds;
    uint256[] public traitList;
    mapping(address => uint256) public userMintCount;

    string public _baseTokenURI;

    bool public presaleActive;
    bool public publicSaleActive;
    uint256 public maxSupply = 2500;
    uint256 public maxMint = 6;
    uint256 public price_1 = 0.01 ether;
    uint256 public price_3 = 0.02 ether;
    uint256 public price_6 = 0.03 ether;

    string public baseTokenUri;
    bytes32 public presaleMerkleRoot;

    uint256[] public trait1 = [1,6,14,51,75,102,113,135,137,157,195,201,210,213,215,241,244,267,268,278,300,341,355,358,363,379,391,404,430,435,478,517,523,525,548,559,573,584,589,598,618,687,695,714,725,730,765,785,814,825,834,904,940,942,993,1031,1077,1088,1102,1111,1128,1158,1160,1175,1194,1199,1224,1263,1273,1309,1342,1345,1377,1379,1416,1419,1425,1449,1452,1464,1471,1472,1484,1507,1510,1532,1533,1560,1572,1598,1604,1610,1637,1640,1689,1700,1705,1706,1707,1734,1736,1754,1761,1776,1811,1813,1863,1882,1888,1892,1901,1910,1917,1929,1959,2003,2057,2076,2086,2103,2116,2137,2155,2157,2191,2257,2258,2260,2266,2270,2273,2299,2305,2337,2406,2428,2442,2460,2478,2487,2499];    
    uint256[] public trait2 = [3,26,33,44,72,105,150,253,284,309,320,411,456,568,569,632,633,748,750,773,958,974,989,1002,1005,1009,1039,1054,1114,1125,1156,1162,1186,1220,1267,1307,1362,1420,1463,1481,1537,1579,1611,1670,1728,1751,1792,1841,1852,1869,1873,1899,1987,2013,2080,2132,2162,2171,2177,2184,2193,2199,2213,2226,2246,2392,2397,2466,2476];
    uint256[] public trait3 = [29,31,45,103,119,136,301,317,332,336,353,376,408,431,549,665,694,741,747,763,847,860,939,954,1069,1070,1078,1106,1110,1182,1193,1200,1212,1242,1255,1314,1343,1366,1436,1535,1571,1583,1655,1685,1709,1788,1859,1954,2023,2051,2064,2077,2153,2164,2172,2174,2218,2225,2249,2322,2361,2366,2371,2417,2469];
    uint256[] public trait4 = [130,142,144,237,327,388,414,466,486,534,582,595,612,638,669,770,807,815,849,869,875,883,887,984,1135,1149,1151,1159,1216,1240,1322,1326,1386,1443,1473,1489,1494,1569,1644,1659,1664,1665,1668,1702,1719,1732,1735,1749,1812,1825,1828,1842,1866,1868,1907,1972,2014,2050,2085,2109,2143,2169,2192,2201,2239,2255,2261,2272,2279,2282,2284,2320,2324,2354,2457
    ];
    uint256[] public trait5 = [80,89,133,165,181,223,234,307,340,370,393,415,450,462,493,516,553,590,594,610,629,657,661,682,710,789,827,843,923,934,1015,1037,1057,1112,1154,1327,1335,1338,1423,1445,1515,1516,1563,1620,1623,1693,1695,1739,1769,1818,1891,1911,1918,1936,1941,1943,1945,1982,2020,2045,2110,2223,2234,2265,2275,2277,2300,2309,2336,2338,2379,2429,2435,2481,2485,2491];
    uint256[] public trait6 = [2,57,73,140,189,199,211,258,294,295,326,349,359,461,587,588,591,651,736,797,806,845,854,949,950,953,967,996,1033,1066,1092,1163,1170,1172,1185,1248,1279,1333,1340,1371,1395,1415,1433,1441,1480,1503,1521,1556,1600,1606,1654,1671,1681,1701,1743,1837,1845,1922,1928,1962,2058,2130,2145,2160,2204,2243,2264,2306,2316,2423,2433

    ];    
    uint256[] public trait7 = [78,151,246,261,271,288,306,367,425,539,562,563,566,602,667,683,728,774,775,786,792,819,867,879,903,920,991,999,1001,1014,1048,1105,1123,1152,1167,1249,1253,1287,1290,1292,1318,1403,1428,1497,1517,1519,1522,1627,1649,1858,1894,1975,1998,2005,2018,2047,2048,2082,2105,2125,2194,2214,2241,2287,2313,2328,2390

    ];
    uint256[] public trait8 = [53,174,186,423,483,605,677,678,729,767,833,841,897,1011,1140,1177,1190,1407,1518,1549,1591,1639,1650,1742,1824,1886,2040,2112,2124,2195,2372,2486

    ];
    uint256[] public trait9 = [8,70,84,127,162,171,204,248,276,322,339,364,558,580,663,684,751,752,781,823,857,876,893,915,946,1024,1051,1081,1116,1180,1276,1328,1364,1388,1393,1477,1512,1543,1544,1614,1621,1684,1760,1771,1803,1816,1832,1919,1944,1963,1974,1997,2056,2096,2181,2244,2267,2289,2307,2438,2451

    ];
    uint256[] public trait10 = [4,143,147,152,193,203,270,293,303,380,412,481,560,592,607,615,621,653,828,895,925,941,969,979,1017,1072,1075,1164,1221,1246,1286,1299,1352,1363,1431,1461,1602,1632,1690,1692,1773,1806,1821,2120,2136,2331,2350,2368,2410,2415,2452

    ];
    uint256[] public trait11 = [34,41,49,63,95,128,148,161,191,207,312,315,316,417,427,465,475,526,535,628,635,641,660,675,697,715,783,804,817,870,908,927,933,978,1041,1071,1080,1096,1117,1129,1150,1178,1197,1214,1265,1293,1298,1361,1404,1462,1482,1498,1524,1573,1585,1597,1609,1666,1762,1793,1952,2019,2025,2037,2094,2129,2146,2150,2158,2196,2251,2276,2310,2360,2363,2377,2396,2418,2470

    ];
    uint256[] public trait12 = [23,37,58,68,100,131,180,183,184,212,227,255,279,310,374,398,400,401,495,574,623,685,848,906,977,981,1000,1022,1038,1049,1086,1104,1189,1211,1223,1243,1295,1310,1336,1686,1694,1696,1699,1711,1741,1798,1871,1889,1903,1940,1942,1979,2044,2113,2187,2221,2250,2268,2335,2355,2434,2473

    ];
    uint256[] public trait13 = [28,62,83,118,179,197,209,233,240,262,426,451,477,528,655,832,886,1082,1139,1235,1325,1375,1397,1411,1439,1525,1529,1618,1641,1643,1740,1801,1834,1844,1848,1874,1902,1978,2084,2095,2097,2228,2262,2367,2386,2401,2407,2409,2472,2496,2498

    ];
    uint256[] public trait14 = [10,21,22,38,42,48,66,79,85,90,94,97,112,117,182,187,214,229,254,277,328,337,381,385,395,405,421,454,455,457,482,522,531,533,543,544,545,547,630,643,658,676,690,693,701,707,713,722,724,738,745,755,791,798,836,846,851,880,917,921,922,929,945,965,985,995,1020,1021,1047,1068,1098,1118,1119,1131,1142,1145,1174,1179,1188,1202,1205,1222,1241,1264,1271,1277,1297,1306,1334,1341,1354,1374,1400,1413,1444,1457,1502,1541,1548,1551,1555,1562,1566,1603,1629,1645,1646,1656,1672,1680,1687,1721,1756,1774,1781,1787,1814,1819,1823,1849,1900,1915,1927,1930,1976,2081,2093,2102,2127,2135,2138,2142,2147,2149,2166,2190,2200,2202,2217,2236,2240,2252,2292,2296,2298,2302,2319,2325,2326,2343,2344,2349,2393,2408,2414,2416,2431,2436,2440,2441,2449,2459,2463,2490

    ];
    uint256[] public trait15 = [5,7,11,30,46,50,60,96,123,146,149,175,205,208,216,224,228,243,249,257,283,289,290,291,298,299,308,311,318,321,344,351,361,383,402,424,432,443,445,447,449,485,491,510,530,540,541,552,561,586,593,600,604,608,609,616,620,622,645,648,652,688,702,704,709,711,719,740,742,743,744,753,769,772,788,790,802,805,808,821,831,844,850,872,874,878,882,889,907,932,935,944,947,948,959,961,962,966,972,973,986,992,1023,1043,1058,1061,1093,1097,1161,1165,1181,1198,1206,1225,1229,1250,1268,1272,1280,1285,1311,1317,1358,1368,1369,1373,1376,1383,1392,1396,1401,1408,1421,1446,1453,1467,1491,1505,1523,1534,1538,1539,1540,1542,1546,1567,1575,1601,1697,1708,1710,1729,1730,1733,1748,1763,1770,1805,1808,1809,1810,1830,1885,1887,1898,1905,1913,1938,1965,1991,1999,2001,2006,2028,2049,2060,2065,2069,2071,2118,2134,2140,2161,2185,2207,2208,2209,2231,2238,2314,2327,2330,2340,2342,2347,2362,2400,2404,2411,2425,2445,2446,2488

    ];
    uint256[] public trait16 = [16,19,20,25,115,121,132,169,190,231,235,371,386,387,428,459,468,474,500,519,536,546,603,654,691,700,726,732,779,812,816,859,885,898,914,951,994,1030,1045,1085,1122,1132,1136,1169,1191,1217,1275,1291,1315,1357,1370,1381,1405,1465,1574,1580,1589,1616,1625,1660,1676,1715,1717,1753,1755,1909,1923,1926,1939,1981,2106,2131,2156,2263,2315,2321,2357,2444,2450,2471

    ];
    uint256[] public trait17 = [40,61,64,81,139,222,282,286,335,345,352,366,373,420,422,496,551,681,733,766,768,787,810,881,901,905,911,912,913,919,1029,1055,1196,1226,1230,1278,1282,1372,1402,1608,1669,1731,1836,1860,1872,1878,1921,1947,1966,1967,2031,2062,2074,2098,2141,2308,2364,2373,2395,2422,2483,2489,2494

    ];
    uint256[] public trait18 = [35,92,93,160,167,177,245,323,350,410,473,484,492,572,642,672,686,727,778,795,811,852,884,998,1008,1012,1036,1040,1042,1052,1107,1108,1134,1147,1157,1176,1215,1304,1316,1329,1331,1385,1391,1398,1500,1506,1596,1635,1678,1800,1838,1854,1934,1957,1983,2009,2016,2066,2070,2087,2100,2151,2152,2219,2220,2230,2248,2253,2281,2387,2432,2448

    ];
    uint256[] public trait19 = [15,65,129,138,145,154,176,206,226,259,266,314,325,333,346,394,418,452,458,471,502,504,518,520,556,637,668,679,731,746,756,757,813,856,877,888,924,960,997,1006,1016,1018,1025,1027,1044,1063,1073,1141,1252,1254,1256,1260,1288,1289,1294,1301,1323,1390,1412,1424,1438,1504,1545,1547,1565,1592,1642,1663,1682,1713,1716,1775,1790,1833,1839,1883,1884,1893,1951,1953,2000,2022,2038,2041,2083,2091,2126,2189,2224,2245,2283,2311,2317,2378,2388,2412,2421

    ];
    uint256[] public trait20 = [12,18,67,108,141,251,280,287,302,324,334,338,354,362,377,499,565,613,636,656,705,864,956,1059,1143,1233,1257,1296,1339,1344,1346,1384,1406,1418,1501,1514,1605,1619,1626,1651,1752,1759,1948,1960,1985,2010,2021,2032,2034,2063,2072,2092,2117,2128,2154,2163,2180,2198,2206,2278,2341

    ];
    uint256[] public trait21 = [27,69,101,107,109,114,122,158,194,219,250,305,330,409,413,436,442,470,480,494,508,529,538,581,599,649,662,716,758,784,830,837,862,891,896,910,918,926,928,938,982,983,1065,1074,1090,1121,1127,1218,1227,1228,1237,1251,1281,1283,1308,1332,1337,1353,1360,1367,1378,1382,1394,1399,1422,1437,1450,1451,1476,1490,1513,1520,1552,1564,1568,1570,1577,1578,1587,1653,1698,1704,1712,1714,1720,1737,1746,1780,1802,1827,1835,1853,1861,1876,1949,1968,1969,1993,2043,2104,2119,2148,2176,2179,2256,2332,2334,2365,2399,2413,2468,2500

    ];
    uint256[] public trait22 = [32,47,56,59,74,76,88,134,155,168,170,172,178,218,252,256,260,272,275,285,399,406,441,469,487,488,498,514,515,550,597,647,666,692,718,800,943,952,963,971,1003,1007,1028,1034,1035,1056,1062,1091,1099,1126,1130,1144,1148,1195,1213,1219,1247,1261,1266,1270,1303,1313,1319,1321,1330,1351,1387,1414,1417,1454,1459,1474,1526,1558,1586,1588,1624,1634,1652,1674,1677,1691,1726,1765,1777,1779,1789,1796,1807,1815,1826,1840,1846,1847,1851,1862,1864,1890,1906,1931,1937,1970,1977,1988,1989,1995,2004,2008,2024,2026,2036,2039,2052,2055,2075,2079,2089,2090,2115,2121,2123,2159,2173,2175,2188,2222,2233,2237,2247,2254,2269,2294,2323,2339,2346,2348,2369,2384,2430,2437,2443,2447,2467,2474,2493,2495,2497

    ];
    uint256[] public trait23 = [36,43,54,82,106,159,173,200,217,238,247,313,329,342,397,416,438,440,446,490,506,512,537,557,576,596,712,723,793,853,900,1004,1095,1115,1146,1166,1187,1192,1204,1486,1495,1527,1576,1590,1631,1745,1747,1757,1768,1920,1964,1973,2007,2015,2017,2046,2101,2133,2167,2280,2288,2356,2389,2403,2454,2455,2475,2484

    ];
    uint256[] public trait24 = [104,153,242,331,343,347,365,372,497,501,555,601,625,646,737,739,754,762,796,835,838,840,855,866,899,1010,1019,1089,1133,1201,1236,1269,1300,1359,1430,1460,1483,1508,1615,1628,1679,1727,1750,1772,1820,1829,1831,1955,1958,1996,2002,2061,2073,2078,2099,2183,2211,2329,2370,2382,2391,2402,2419,2456

    ];
    uint256[] public trait25 = [71,124,225,281,319,348,356,368,375,463,624,650,671,674,680,720,764,776,794,801,809,865,873,916,964,968,976,980,987,1046,1079,1103,1274,1284,1349,1410,1509,1593,1595,1607,1636,1662,1688,1725,1758,1778,1782,1795,1797,1804,1856,1875,1877,1880,1904,1984,1990,1994,2107,2122,2144,2178,2186,2216,2227,2274,2312,2381,2383,2385,2420,2480

    ];
    uint256[] public trait26 = [17,52,55,77,86,87,110,111,116,120,125,126,156,166,188,196,198,202,220,221,269,273,304,357,369,378,382,384,403,407,419,433,448,453,464,489,503,509,511,513,532,564,577,578,579,583,611,614,627,631,644,670,673,698,699,703,708,721,749,759,760,777,780,799,803,818,820,822,824,826,842,858,861,868,871,890,892,936,955,957,975,1032,1050,1053,1064,1067,1076,1084,1094,1109,1113,1124,1137,1153,1155,1173,1184,1203,1209,1244,1259,1305,1324,1347,1348,1355,1365,1380,1389,1426,1427,1429,1442,1448,1458,1468,1499,1531,1550,1553,1557,1559,1561,1581,1582,1613,1617,1622,1647,1657,1658,1661,1667,1718,1723,1738,1744,1784,1785,1799,1855,1865,1867,1879,1895,1908,1912,1935,1946,1950,1956,1961,2012,2029,2035,2054,2059,2067,2068,2088,2111,2165,2170,2182,2197,2205,2210,2212,2232,2259,2304,2333,2352,2353,2358,2376,2426,2427,2458,2461,2464,2482

    ];
    uint256[] public trait27 = [9,13,24,39,91,98,99,163,164,185,192,230,232,236,239,263,264,265,274,292,296,297,360,389,390,392,396,429,434,437,439,444,460,467,472,476,479,505,507,521,524,527,542,554,567,570,571,575,585,606,617,619,626,634,639,640,659,664,689,696,706,717,734,735,761,771,782,829,839,863,894,902,909,930,931,937,970,988,990,1013,1026,1060,1083,1087,1100,1101,1120,1138,1168,1171,1183,1207,1208,1210,1231,1232,1234,1238,1239,1245,1258,1262,1302,1312,1320,1350,1356,1409,1432,1434,1435,1440,1447,1455,1456,1466,1469,1470,1475,1478,1479,1485,1487,1488,1492,1493,1496,1511,1528,1530,1536,1554,1584,1594,1599,1612,1630,1633,1638,1648,1673,1675,1683,1703,1722,1724,1764,1766,1767,1783,1786,1791,1794,1817,1822,1843,1850,1857,1870,1881,1896,1897,1914,1916,1924,1925,1932,1933,1971,1980,1986,1992,2011,2027,2030,2033,2042,2053,2108,2114,2139,2168,2203,2215,2229,2235,2242,2271,2285,2286,2290,2291,2293,2295,2297,2301,2303,2318,2345,2351,2359,2374,2375,2380,2394,2398,2405,2424,2439,2462,2465,2477,2479,2492

    ];
    constructor() ERC721("TraitBasedNFT", "TNFT") {
        _baseTokenURI = "https://nftstorage.link/ipfs/bafybeiemwrvmq4mxmzyv5yx5u4thrdmxqvzh2qzccd4o6sm4zitk4qqnfu/";

        uint256[] memory traitCounts = new uint256[](27);
        traitCounts[0] = trait1.length;
        traitCounts[1] = trait2.length;
        traitCounts[2] = trait3.length;
        traitCounts[3] = trait4.length;
        traitCounts[4] = trait5.length;
        traitCounts[5] = trait6.length;
        traitCounts[6] = trait7.length;
        traitCounts[7] = trait8.length;
        traitCounts[8] = trait9.length;
        traitCounts[9] = trait10.length;
        traitCounts[10] = trait11.length;
        traitCounts[11] = trait12.length;
        traitCounts[12] = trait13.length;
        traitCounts[13] = trait14.length;
        traitCounts[14] = trait15.length;
        traitCounts[15] = trait16.length;
        traitCounts[16] = trait17.length;
        traitCounts[17] = trait18.length;
        traitCounts[18] = trait19.length;
        traitCounts[19] = trait20.length;
        traitCounts[20] = trait21.length;
        traitCounts[21] = trait22.length;
        traitCounts[22] = trait23.length;
        traitCounts[23] = trait24.length;
        traitCounts[24] = trait25.length;
        traitCounts[25] = trait26.length;
        traitCounts[26] = trait27.length;

        for (uint256 i = 0; i < trait1.length; i++) {
            availableTokenIds.push(trait1[i]);
            traitToTokenIds[1].add(trait1[i]);
        }

        for (uint256 i = 0; i < trait2.length; i++) {
            availableTokenIds.push(trait2[i]);
            traitToTokenIds[2].add(trait2[i]);
        }

        for (uint256 i = 0; i < trait3.length; i++) {
            availableTokenIds.push(trait3[i]);
            traitToTokenIds[3].add(trait3[i]);
        }

        for (uint256 i = 0; i < trait4.length; i++) {
            availableTokenIds.push(trait4[i]);
            traitToTokenIds[4].add(trait4[i]);
        }

        for (uint256 i = 0; i < trait5.length; i++) {
            availableTokenIds.push(trait5[i]);
            traitToTokenIds[5].add(trait5[i]);
        }

        for (uint256 i = 0; i < trait6.length; i++) {
            availableTokenIds.push(trait6[i]);
            traitToTokenIds[6].add(trait6[i]);
        }

        for (uint256 i = 0; i < trait7.length; i++) {
            availableTokenIds.push(trait7[i]);
            traitToTokenIds[7].add(trait7[i]);
        }

        for (uint256 i = 0; i < trait8.length; i++) {
            availableTokenIds.push(trait8[i]);
            traitToTokenIds[8].add(trait8[i]);
        }

        for (uint256 i = 0; i < trait9.length; i++) {
            availableTokenIds.push(trait9[i]);
            traitToTokenIds[9].add(trait9[i]);
        }

        for (uint256 i = 0; i < trait10.length; i++) {
            availableTokenIds.push(trait10[i]);
            traitToTokenIds[10].add(trait10[i]);
        }

        for (uint256 i = 0; i < trait11.length; i++) {
            availableTokenIds.push(trait11[i]);
            traitToTokenIds[11].add(trait11[i]);
        }

        for (uint256 i = 0; i < trait12.length; i++) {
            availableTokenIds.push(trait12[i]);
            traitToTokenIds[12].add(trait12[i]);
        }

        for (uint256 i = 0; i < trait13.length; i++) {
            availableTokenIds.push(trait13[i]);
            traitToTokenIds[13].add(trait13[i]);
        }

        for (uint256 i = 0; i < trait14.length; i++) {
            availableTokenIds.push(trait14[i]);
            traitToTokenIds[14].add(trait14[i]);
        }

        for (uint256 i = 0; i < trait15.length; i++) {
            availableTokenIds.push(trait15[i]);
            traitToTokenIds[15].add(trait15[i]);
        }

        for (uint256 i = 0; i < trait16.length; i++) {
            availableTokenIds.push(trait16[i]);
            traitToTokenIds[16].add(trait16[i]);
        }

        for (uint256 i = 0; i < trait17.length; i++) {
            availableTokenIds.push(trait17[i]);
            traitToTokenIds[17].add(trait17[i]);
        }

        for (uint256 i = 0; i < trait18.length; i++) {
            availableTokenIds.push(trait18[i]);
            traitToTokenIds[18].add(trait18[i]);
        }

        for (uint256 i = 0; i < trait19.length; i++) {
            availableTokenIds.push(trait19[i]);
            traitToTokenIds[19].add(trait19[i]);
        }

        for (uint256 i = 0; i < trait20.length; i++) {
            availableTokenIds.push(trait20[i]);
            traitToTokenIds[20].add(trait20[i]);
        }

        for (uint256 i = 0; i < trait21.length; i++) {
            availableTokenIds.push(trait21[i]);
            traitToTokenIds[21].add(trait21[i]);
        }

        for (uint256 i = 0; i < trait22.length; i++) {
            availableTokenIds.push(trait22[i]);
            traitToTokenIds[22].add(trait22[i]);
        }

        for (uint256 i = 0; i < trait23.length; i++) {
            availableTokenIds.push(trait23[i]);
            traitToTokenIds[23].add(trait23[i]);
        }

        for (uint256 i = 0; i < trait24.length; i++) {
            availableTokenIds.push(trait24[i]);
            traitToTokenIds[24].add(trait24[i]);
        }

        for (uint256 i = 0; i < trait25.length; i++) {
            availableTokenIds.push(trait25[i]);
            traitToTokenIds[25].add(trait25[i]);
        }

        for (uint256 i = 0; i < trait26.length; i++) {
            availableTokenIds.push(trait26[i]);
            traitToTokenIds[26].add(trait26[i]);
        }

        for (uint256 i = 0; i < trait27.length; i++) {
            availableTokenIds.push(trait27[i]);
            traitToTokenIds[27].add(trait27[i]);
        }
    
    }

    modifier callerIsUser() {
        if (msg.sender != tx.origin) revert NoContracts();
        _;
    }

    function getTraitTokenCount(uint256 trait) public view returns (uint256) {
        return traitToTokenIds[trait].length();
    }

    function getTraitTokenByIndex(uint256 trait, uint256 index)
        public
        view
        returns (uint256)
    {
        return traitToTokenIds[trait].at(index);
    }

    function setBaseTokenURI(string memory newBaseTokenURI) public onlyOwner {
        _baseTokenURI = newBaseTokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 _tokenId)
        public
        pure
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    "https://nftstorage.link/ipfs/bafybeiemwrvmq4mxmzyv5yx5u4thrdmxqvzh2qzccd4o6sm4zitk4qqnfu/",
                    Strings.toString(_tokenId),
                    ".json"
                )
            );
    }

    function togglePresale() external onlyOwner {
        presaleActive = !presaleActive;
    }

    function togglePublicSale() external onlyOwner {
        publicSaleActive = !publicSaleActive;
    }

    function setPresaleMerkleRoot(bytes32 _presaleMerkleRoot)
        external
        onlyOwner
    {
        presaleMerkleRoot = _presaleMerkleRoot;
    }

    function setPrice_1(uint256 _price_1) external onlyOwner {
        price_1 = _price_1;
    }

    function setPrice_3(uint256 _price_3) external onlyOwner {
        price_3 = _price_3;
    }

    function setPrice_6(uint256 _price_6) external onlyOwner {
        price_6 = _price_6;
    }

    function mintWithTraitOG(
        uint256 _trait,
        uint256 _quantity,
        bytes32[] calldata _proof
    ) external payable callerIsUser {
        require(_quantity > 0 && _quantity <= maxMint, "Invalid quantity");
        require(
            traitToTokenIds[_trait].length() >= _quantity,
            "Not enough tokens with this trait left"
        );
        require(
            MerkleProof.verify(
                _proof,
                presaleMerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Not on the whitelist"
        );

        if (!presaleActive) revert PreSaleNotActive();

        uint256 price;
        uint256 previousTransactions = userMintCount[msg.sender];

        if (previousTransactions == 0) {
            price = price_1;
        } else if (previousTransactions == 1) {
            price = 0;
        } else if (previousTransactions >= 2 && _quantity == 1) {
            price = price_1;
        } else if (previousTransactions >= 2 && _quantity <= 3) {
            price = price_3;
        } else if (previousTransactions >= 2) {
            price = price_6;
        }

        require(msg.value >= price, "Insufficient ETH");

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 randomIndex = _random(traitToTokenIds[_trait].length());
            uint256 tokenId = traitToTokenIds[_trait].at(randomIndex);
            traitToTokenIds[_trait].remove(tokenId);
            _mint(msg.sender, tokenId);
            mintedTokens[tokenId] = true;
        }

        userMintCount[msg.sender] += 1;
    }

    function mintWithTraitPresale(
        uint256 _trait,
        uint256 _quantity,
        bytes32[] calldata _proof
    ) external payable callerIsUser {
        require(_quantity > 0 && _quantity <= maxMint, "Invalid quantity");
        require(
            traitToTokenIds[_trait].length() >= _quantity,
            "Not enough tokens with this trait left"
        );
        require(
            MerkleProof.verify(
                _proof,
                presaleMerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Not on the whitelist"
        );

        if (!presaleActive) revert PreSaleNotActive();

        uint256 price;

        if (_quantity == 1) {
            price = price_1;
        } else if (_quantity <= 3) {
            price = price_3;
        } else {
            price = price_6;
        }

        require(msg.value >= price, "Insufficient ETH");

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 randomIndex = _random(traitToTokenIds[_trait].length());
            uint256 tokenId = traitToTokenIds[_trait].at(randomIndex);
            traitToTokenIds[_trait].remove(tokenId);
            _mint(msg.sender, tokenId);
            mintedTokens[tokenId] = true;
        }

        userMintCount[msg.sender] += 1;
    }

    function mintWithTraitPublic(uint256 _trait, uint256 _quantity)
        external
        payable
        callerIsUser
    {
        require(_quantity > 0 && _quantity <= maxMint, "Invalid quantity");
        require(
            traitToTokenIds[_trait].length() >= _quantity,
            "Not enough tokens with this trait left"
        );

        if (!publicSaleActive) revert PublicSaleNotActive();

        uint256 price;
        if (_quantity == 1) {
            price = price_1;
        } else if (_quantity <= 3) {
            price = price_3;
        } else {
            price = price_6;
        }

        require(msg.value >= price, "Insufficient ETH");

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 randomIndex = _random(traitToTokenIds[_trait].length());
            uint256 tokenId = traitToTokenIds[_trait].at(randomIndex);
            traitToTokenIds[_trait].remove(tokenId);

            _safeMint(msg.sender, tokenId);

            emit Transfer(address(0), msg.sender, tokenId);
            mintedTokens[tokenId] = true;
        }

        userMintCount[msg.sender] += 1;
    }

    function _random(uint256 _limit) private view returns (uint256) {
        return
            uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) %
            _limit;
    }

    function isValid(address _user, bytes32[] calldata _proof)
        external
        view
        returns (bool)
    {
        return
            MerkleProof.verify(
                _proof,
                presaleMerkleRoot,
                keccak256(abi.encodePacked(_user))
            );
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}
