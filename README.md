<h1 align="center"> 
  NucleiFuzzer = Nuclei + Paramspider + waybackurls + gauplus + hakrawler + katana + Fuzzing Templates
  <br>
</h1>

<p align="center">
<a href="https://github.com/0xKayala/NucleiFuzzer/issues"><img src="https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat"></a>
<a href="https://github.com/0xKayala/NucleiFuzzer/releases"><img src="https://img.shields.io/github/v/release/0xkayala/NucleiFuzzer.svg"></a>
<a href="https://twitter.com/0xKayala"><img src="https://img.shields.io/twitter/follow/0xKayala.svg?logo=twitter"></a>
</p>

## Overview
`NucleiFuzzer` is an advanced automation tool designed to streamline and optimize web application security testing by integrating a suite of powerful URL discovery and vulnerability scanning tools. It combines `ParamSpider`, `Waybackurls`, `Katana`, `Gauplus`, and `Hakrawler` to comprehensively gather and enumerate potential entry points for web applications. Leveraging the power of `Nuclei`, it scans these endpoints using `fuzzing-templates` to effectively uncover a wide range of vulnerabilities.

The enhanced `NucleiFuzzer` is built for speed and accuracy, utilizing advanced URL validation, deduplication with `uro`, and precise HTTP filtering using `httpx`. This tool provides `security professionals`, `bug bounty hunters`, and `web developers` with a seamless workflow to detect and address security risks, ensuring robust web application protection.

## Key Features:
1. Comprehensive URL Discovery: Integrates multiple tools (`ParamSpider`, `Waybackurls`, `Katana`, `Gauplus`, and `Hakrawler`) to ensure exhaustive coverage of URLs and parameters.
2. Enhanced Vulnerability Scanning: Uses `Nuclei` with `fuzzing-templates` to identify critical security issues with precision.
3. Advanced Filtering and Validation: Removes duplicates and irrelevant results using `uro` and `httpx` for cleaner and more focused scanning.
4. Rate Limiting for Efficiency: Allows customizable request rates for optimal performance during scans.
5. Customizable and User-Friendly: Easy-to-configure options for domains, files, and output directories, catering to both individual and batch scans.

Take advantage of `NucleiFuzzer` to safeguard your web applications against vulnerabilities and attacks with an enhanced, efficient, and reliable security testing solution!

**Note:** `Nuclei` + `Paramspider` + `waybackurls` + `gauplus` + `hakrawler` + `katana` + `Fuzzing Templates` = `NucleiFuzzer` <br><br>
**Important:** Make sure the tools `Nuclei`, `Paramspider`, `waybackurls`, `gauplus`, `hakrawler`, `katana`, `httpx` & `uro` are installed on your machine and executing correctly to use the `NucleiFuzzer` without any issues.

### Tools included:
- [Nuclei](https://github.com/projectdiscovery/nuclei) `git clone https://github.com/projectdiscovery/nuclei.git`<br>
- [ParamSpider](https://github.com/0xKayala/ParamSpider) `git clone https://github.com/0xKayala/ParamSpider.git`<br>
- [waybackurls](https://github.com/tomnomnom/waybackurls) `git clone https://github.com/tomnomnom/waybackurls.git`<br>
- [gauplus](https://github.com/bp0lr/gauplus) `git clone https://github.com/bp0lr/gauplus.git`<br>
- [hakrawler](https://github.com/hakluke/hakrawler) `git clone https://github.com/hakluke/hakrawler.git`<br>
- [katana](https://github.com/projectdiscovery/katana) `git clone https://github.com/projectdiscovery/katana.git`<br>
- [httpx](https://github.com/projectdiscovery/httpx) `git clone https://github.com/projectdiscovery/httpx.git`<br>
- [uro](https://github.com/s0md3v/uro) `https://github.com/s0md3v/uro.git`<br>


### Templates:
[Fuzzing Templates](https://github.com/projectdiscovery/nuclei-templates) `git clone https://github.com/projectdiscovery/nuclei-templates.git`

## Screenshot
![image](https://github.com/user-attachments/assets/2361a57a-7e82-47ac-832f-d83088e71ea3)


## Output
![image](https://github.com/user-attachments/assets/f26e6b1e-8bf9-4781-ab08-fe02f19931e3)
![image](https://github.com/user-attachments/assets/0336b4c2-51e6-4a2f-8994-8fc0717d2b75)
![image](https://github.com/user-attachments/assets/8293b1bb-2f8b-4678-bb76-d5da9eea6d05)


## Usage

```sh
nf -h
```

This will display help for the tool. Here are the options it supports.

```console
NucleiFuzzer: A Powerful Automation Tool for Web Vulnerability Scanning

Usage: /usr/bin/nf [options]

Options:
  -h, --help              Display help information
  -d, --domain <domain>   Single domain to scan for vulnerabilities
  -f, --file <filename>   File containing multiple domains/URLs to scan
  -o, --output <folder>   Specify output folder for scan results (default: ./output)
```  

## Installation:

To install `NucleiFuzzer`, follow these steps:

```
git clone https://github.com/0xKayala/NucleiFuzzer.git && cd NucleiFuzzer && sudo chmod +x install.sh && ./install.sh && (command -v nf &> /dev/null && nf -h || echo "Installation failed: Command 'nf' not found. Please check for errors during installation.") && cd .. || echo "Failed to clone or navigate to NucleiFuzzer repository. Please check your setup."
```

## Examples:

Here are a few examples of how to use NucleiFuzzer:

- Run `NucleiFuzzer` on a single domain:

  ```sh
  nf -d example.com
  ```

- Run `NucleiFuzzer` on multiple domains from a file:

  ```sh
  nf -f file.txt
  ```

## Practical Demonstration:

For a Practical Demonstration of the NucleiFuzzer tool see the below video 👇 <br>

[<img src="https://img.youtube.com/vi/2K2gTCHt6kg/hqdefault.jpg" width="600" height="300"/>](https://www.youtube.com/embed/2K2gTCHt6kg)

## Star History

<a href="https://star-history.com/#0xKayala/NucleiFuzzer&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=0xKayala/NucleiFuzzer&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=0xKayala/NucleiFuzzer&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=0xKayala/NucleiFuzzer&type=Date" />
 </picture>
</a>

## Contributing

Contributions are welcome! If you'd like to contribute to `NucleiFuzzer`, please follow these steps:

1. Fork the repository.
2. Create a new branch.
3. Make your changes and commit them.
4. Submit a pull request.

Made by
`Satya Prakash` | `0xKayala` \

A `Security Researcher` and `Bug Hunter` \

## Connect with me:
<p align="left">
<a href="https://twitter.com/0xkayala" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/twitter.svg" alt="0xkayala" height="30" width="40" /></a>
<a href="https://linkedin.com/in/0xkayala" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/linked-in-alt.svg" alt="0xkayala" height="30" width="40" /></a>
<a href="https://instagram.com/0xkayala" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/instagram.svg" alt="0xkayala" height="30" width="40" /></a>
<a href="https://medium.com/@0xkayala" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/medium.svg" alt="@0xkayala" height="30" width="40" /></a>
<a href="https://www.youtube.com/@0xkayala" target="blank"><img align="center" src="https://raw.githubusercontent.com/rahuldkjain/github-profile-readme-generator/master/src/images/icons/Social/youtube.svg" alt="0xkayala" height="30" width="40" /></a>
</p>

## Support me:
<p><a href="https://www.buymeacoffee.com/0xKayala"> <img align="left" src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" height="50" width="210" alt="0xKayala" /></a></p><br><br>
