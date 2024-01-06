# NucleiFuzzer = Nuclei + Paramspider

<p align="center">
<a href="https://github.com/0xKayala/NucleiFuzzer/issues"><img src="https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat"></a>
<a href="https://github.com/0xKayala/NucleiFuzzer/releases"><img src="https://img.shields.io/github/v/release/0xkayala/NucleiFuzzer.svg"></a>
<a href="https://twitter.com/0xKayala"><img src="https://img.shields.io/twitter/follow/0xKayala.svg?logo=twitter"></a>
</p>

`NucleiFuzzer` is an automation tool that combines `ParamSpider` and `Nuclei` to enhance web application security testing. It uses `ParamSpider` to identify potential entry points and `Nuclei's` templates to scan for vulnerabilities. `NucleiFuzzer` streamlines the process, making it easier for security professionals and web developers to detect and address security risks efficiently. Download `NucleiFuzzer` to protect your web applications from vulnerabilities and attacks.

**Note:** `Nuclei` + `Paramspider` = `NucleiFuzzer` <br><br>
**Important:** Make sure the tools `Nuclei`, `httpx` & `Paramspider` are installed on your machine and executing correctly to use the `NucleiFuzzer` without any issues.

### Tools included:
[ParamSpider](https://github.com/0xKayala/ParamSpider) `git clone https://github.com/0xKayala/ParamSpider.git`<br><br>
[Nuclei](https://github.com/projectdiscovery/nuclei) `git clone https://github.com/projectdiscovery/nuclei.git`

### Templates:
[Fuzzing Templates](https://github.com/0xKayala/fuzzing-templates) `git clone https://github.com/0xKayala/fuzzing-templates.git`

# Screenshot
![image](https://github.com/0xKayala/NucleiFuzzer/assets/16838353/d29d18e2-e5b4-4f5f-b1fd-351167fa7c31)





# Output
![image](https://github.com/0xKayala/NucleiFuzzer/assets/16838353/16c8eac9-6924-4196-ae71-70e98057e47c)
![image](https://github.com/0xKayala/NucleiFuzzer/assets/16838353/2b204838-d3ed-4408-9920-ba99a9c528a2)
![image](https://github.com/0xKayala/NucleiFuzzer/assets/16838353/304f8113-6b65-4ae8-8d23-34bcee750b73)

## Usage

```sh
nf -h
```

This will display help for the tool. Here are the options it supports.

```console
NucleiFuzzer is a Powerful Automation tool for detecting XSS, SQLi, SSRF, Open-Redirect, etc. vulnerabilities in Web Applications

Usage: /usr/local/bin/nf [options]

Options:
  -h, --help              Display help information
  -d, --domain <domain>   Domain to scan for XSS, SQLi, SSRF, Open-Redirect..etc vulnerabilities
  -f, --file <filename>   File containing multiple domains/URLs to scan
```  

## Installation:

To install `NucleiFuzzer`, follow these steps:

```
git clone https://github.com/0xKayala/NucleiFuzzer.git
cd NucleiFuzzer
sudo chmod +x install.sh
./install.sh
nf -h
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

[![Star History Chart](https://api.star-history.com/svg?repos=0xKayala/NucleiFuzzer&type=Date)](https://star-history.com/#0xKayala/NucleiFuzzer&Date)

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
<p><a href="https://www.buymeacoffee.com/satyakayala"> <img align="left" src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" height="50" width="210" alt="satyakayala" /></a></p><br><br>
