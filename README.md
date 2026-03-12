## perl-playground

Most of these scripts can be found in "Network Programming with Perl" by Lincoln D. Stein.
Some have been updated slightly while others are wholly of my own creation.

I hope they are as useful to you as they are to me.

### Script Catalog

#### Network Clients & Servers

| Script | Description |
|--------|-------------|
| `daytime_cli.pl` | Daytime protocol client using raw Socket constants |
| `daytime_cli2.pl` | Daytime client using Socket helper functions (`gethostbyname`, `getservbyname`) |
| `time_of_day_tcp2.pl` | Daytime client using IO::Socket — simplest high-level approach |
| `tcp_echo_cli1.pl` | Echo client (low-level Socket), tracks bytes sent/received |
| `tcp_echo_cli2.pl` | Echo client (IO::Socket), cleaner high-level equivalent |
| `tcp_echo_serv1.pl` | Echo server (low-level Socket), reverses messages |
| `tcp_echo_serv2.pl` | Echo server (IO::Socket) with CRLF handling |
| `gab2.pl` | Forking TCP chat client — bidirectional I/O with `fork()` |
| `web_fetch.pl` | Raw HTTP client — manually constructs GET requests over a socket |

#### DNS & Network Utilities

| Script | Description |
|--------|-------------|
| `ip_trans.pl` | Hostname → IP using older Socket API (`gethostbyname`/`inet_ntoa`) |
| `ip_trans2.pl` | Hostname → IP using modern Socket API (`getaddrinfo`/`getnameinfo`) |
| `name_trans.pl` | Reverse DNS: IP → hostname |

#### Web Scraping & Data Retrieval

| Script | Description |
|--------|-------------|
| `get_url.pl` | Fetch a URL and extract text via `HTML::TokeParser::Simple` |
| `scraper.pl` | Selenium-driven scraper with Moo OOP; outputs CSV |
| `fetch_nix_rfcs.pl` | Download NixOS RFCs from GitHub (JSON parsing, CLI flags) |
| `mirror_rfc.pl` | Mirror RFC documents from faqs.org to local files |
| `ftp_recent.pl` | FTP client that pulls the RECENT file from CPAN |

#### Unix & System Programming

| Script | Description |
|--------|-------------|
| `daemonize.pl` | Classic daemonization: `fork`, `setsid`, redirect to `/dev/null` |
| `sighup_example.pl` | POSIX signal handling — catches SIGHUP and restarts itself |

#### Algorithms & Utilities

| Script | Description |
|--------|-------------|
| `markov.pl` | Markov chain text generator with configurable n-gram prefix size |
| `bs.pl` | Binary search over a sorted file using `seek`/`tell` |
