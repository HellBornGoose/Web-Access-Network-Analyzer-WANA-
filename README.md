# Web Access Network Analyzer (WANA)

## Description
`wana.sh` is a versatile shell script designed to parse, filter, and analyze standard web server access logs (e.g., Apache, Nginx). It allows system administrators and developers to quickly extract unique IP addresses, resolve hostnames, view requested URIs, and generate visual histograms of server load or visitor activity.

## Features
- **Transparent Decompression**: Automatically handles both plain text and `.gz` compressed log files.
- **Piping Support**: Can read from standard input (`stdin`) or directly from specified files.
- **Time-based Filtering**: Filter logs within a specific timeframe (after or before a given date).
- **Visual Histograms**: Generates text-based bar charts for quick traffic analysis.
- **DNS Resolution**: Capable of performing reverse DNS lookups on client IP addresses.

## Prerequisites
The script relies on standard Unix/Linux utilities. Ensure the following are available on your system:
- `gawk` (GNU awk)
- `host` (for DNS resolution in the `list-hosts` command)
- `gunzip` (for reading compressed logs)

## Usage
The script requires exactly one **command**, accepts optional **filters**, and can process one or more **log files**.

```bash
./wana.sh [FILTER(S)] [COMMAND] [FILE(S)...]
