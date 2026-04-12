#!/usr/bin/env python3

import os
import sys
import json
import argparse
import subprocess
import shutil
from pathlib import Path
from colorama import init, Fore, Style

# Initialize colorama for cross-platform color support
init(autoreset=True)

# ==========================================
# 🔥 NUCLEIFUZZER v4.0 - PYTHON AI ENGINE
# ==========================================

class NucleiFuzzer:
    def __init__(self, args):
        self.domain = args.domain
        self.filename = args.file
        self.ai_mode = args.ai
        self.fast_mode = args.fast
        self.deep_mode = args.deep
        self.doctor = args.doctor
        self.update = args.update
        
        self.base_dir = Path(__file__).parent.absolute()
        self.output_dir = self.base_dir / "output"
        self.proofs_dir = self.output_dir / "proofs"
        
        # Ensure directories exist
        self.output_dir.mkdir(exist_ok=True)
        self.proofs_dir.mkdir(exist_ok=True)
        
        # Output files
        self.raw_file = self.output_dir / "raw.txt"
        self.validated_file = self.output_dir / "validated.txt"
        self.json_file = self.output_dir / "results.json"
        self.js_file = self.output_dir / "js_endpoints.txt"
        self.ai_file = self.output_dir / "ai_insights.txt"

    def show_banner(self):
        banner = f"""{Fore.RED}
███╗   ██╗██╗   ██╗ ██████╗██╗     ███████╗██╗███████╗██╗   ██╗███████╗███████╗███████╗██████╗ 
████╗  ██║██║   ██║██╔════╝██║     ██╔════╝██║██╔════╝██║   ██║╚══███╔╝╚══███╔╝██╔════╝██╔══██╗
██╔██╗ ██║██║   ██║██║     ██║     █████╗  ██║█████╗  ██║   ██║  ███╔╝   ███╔╝ █████╗  ██████╔╝
██║╚██╗██║██║   ██║██║     ██║     ██╔══╝  ██║██╔══╝  ██║   ██║ ███╔╝   ███╔╝  ██╔══╝  ██╔══██╗
██║ ╚████║╚██████╔╝╚██████╗███████╗███████╗██║██║     ╚██████╔╝███████╗███████╗███████╗██║  ██║
╚═╝  ╚═══╝ ╚═════╝  ╚═════╝╚══════╝╚══════╝╚═╝╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
                                               
                                            ⚡ NucleiFuzzer v4.0 (Python + AI + Active Validation)
                                               Next-Gen Offensive Intelligence Framework
{Style.RESET_ALL}"""
        print(banner)

    def run_command(self, cmd, silent=False):
        """Helper to run shell commands via Python subprocess"""
        try:
            if silent:
                subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                subprocess.run(cmd, shell=True, check=True)
        except subprocess.CalledProcessError as e:
            print(f"{Fore.RED}[WARN] Command failed: {cmd}{Style.RESET_ALL}")

    # ==========================================
    # 🔍 RECON & CRAWLING (Python Orchestrated)
    # ==========================================
    def recon_and_crawl(self, target):
        print(f"{Fore.BLUE}[*] Starting Recon & Crawling for {target}...{Style.RESET_ALL}")
        
        # Parallel execution using bash backgrounding, managed by Python
        recon_cmd = f"""
        python3 ~/ParamSpider/paramspider.py -d {target} --quiet -o {self.output_dir}/param.txt &
        echo {target} | waybackurls > {self.output_dir}/wayback.txt &
        echo {target} | katana -d 3 -silent > {self.output_dir}/katana.txt &
        wait
        cat {self.output_dir}/*.txt | grep -aE '^https?://' | sort -u | uro > {self.raw_file}
        """
        self.run_command(recon_cmd)
        
        # Extract JS files for Deep AI analysis
        js_cmd = f"grep -aEi '\.js(\?|$)' {self.raw_file} > {self.js_file}"
        self.run_command(js_cmd, silent=True)
        
        print(f"{Fore.GREEN}[✔] Recon Complete. Data saved to {self.raw_file}{Style.RESET_ALL}")

    # ==========================================
    # ⚡ NUCLEI SCANNING
    # ==========================================
    def run_nuclei_scan(self):
        print(f"{Fore.GREEN}[*] Probing live hosts with httpx...{Style.RESET_ALL}")
        self.run_command(f"httpx -silent -l {self.raw_file} -o {self.validated_file}")

        rate = 200 if self.fast_mode else 50
        print(f"{Fore.GREEN}[*] Running Nuclei DAST Scan (Rate: {rate})...{Style.RESET_ALL}")
        
        nuclei_cmd = f"nuclei -l {self.validated_file} -dast -severity critical,high,medium -rl {rate} -jsonl -silent -o {self.json_file}"
        self.run_command(nuclei_cmd)

    # ==========================================
    # 🎯 ACTIVE VALIDATOR (BugTraceAI Style)
    # ==========================================
    def active_validation(self):
        print(f"\n{Fore.CYAN}[*] Initializing Active Validation Engine...{Style.RESET_ALL}")
        
        if not self.json_file.exists() or self.json_file.stat().st_size == 0:
            print("[INFO] No vulnerabilities found to validate.")
            return

        with open(self.json_file, 'r') as f:
            findings = [json.loads(line) for line in f if line.strip()]

        # Validate SQLi
        sqli_targets = [f['matched-at'] for f in findings if 'sqli' in f.get('info', {}).get('name', '').lower()]
        if sqli_targets and shutil.which("sqlmap"):
            print(f"{Fore.YELLOW}[!] Potential SQLi detected. Triggering SQLMap...{Style.RESET_ALL}")
            for target in set(sqli_targets):
                print(f"[*] Attacking: {target}")
                cmd = f"sqlmap -u \"{target}\" --batch --level 1 --risk 1 --dbs --output-dir={self.proofs_dir}/sqlmap"
                self.run_command(cmd, silent=True)
                print(f"{Fore.GREEN}[+] SQLMap execution finished for {target}{Style.RESET_ALL}")

        # Validate XSS
        xss_targets = [f['matched-at'] for f in findings if 'xss' in f.get('info', {}).get('name', '').lower()]
        if xss_targets and shutil.which("dalfox"):
            print(f"{Fore.YELLOW}[!] Potential XSS detected. Triggering Dalfox...{Style.RESET_ALL}")
            xss_file = self.output_dir / "xss_targets.txt"
            with open(xss_file, 'w') as f:
                f.write("\n".join(set(xss_targets)))
            
            cmd = f"dalfox file {xss_file} -o {self.proofs_dir}/xss_confirmed.txt"
            self.run_command(cmd, silent=True)

    # ==========================================
    # 🧠 DEEP JS & AI ANALYSIS (VulnHawk Style)
    # ==========================================
    def deep_ai_analysis(self):
        if not self.ai_mode:
            return
            
        print(f"\n{Fore.BLUE}[*] Running Deep AI Context Analysis...{Style.RESET_ALL}")
        
        gemini_key = os.environ.get("GEMINI_API_KEY")
        if not gemini_key:
            print(f"{Fore.RED}[WARN] GEMINI_API_KEY not found. Skipping AI analysis.{Style.RESET_ALL}")
            return

        import requests
        
        def call_gemini(prompt):
            url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={gemini_key}"
            headers = {'Content-Type': 'application/json'}
            data = {"contents": [{"parts": [{"text": prompt}]}]}
            try:
                response = requests.post(url, headers=headers, json=data)
                return response.json()['candidates'][0]['content']['parts'][0]['text']
            except Exception as e:
                return f"AI API Error: {str(e)}"

        with open(self.ai_file, 'w') as out:
            out.write("=== 🧠 DEEP AI SECURITY INSIGHTS ===\n\n")

            # Phase 1: JS Logic Extraction
            if self.js_file.exists() and self.js_file.stat().st_size > 0:
                print(f"{Fore.CYAN}[*] Analyzing JS files for hidden business logic...{Style.RESET_ALL}")
                with open(self.js_file, 'r') as f:
                    js_urls = [line.strip() for line in f.readlines()[:3]] # Top 3 to save tokens
                
                for url in js_urls:
                    print(f"[*] AI Analyzing: {url}")
                    try:
                        js_content = requests.get(url, timeout=5).text[:8000]
                        prompt = f"You are a bug bounty hunter. Read this JS snippet. Extract hidden API endpoints, hardcoded secrets, and AWS keys as a bulleted list. Code: {js_content}"
                        analysis = call_gemini(prompt)
                        out.write(f"[*] Findings for {url}:\n{analysis}\n\n")
                    except:
                        pass

            # Phase 2: Vulnerability Chaining
            if self.json_file.exists() and self.json_file.stat().st_size > 0:
                print(f"{Fore.CYAN}[*] Generating Attack Chains...{Style.RESET_ALL}")
                with open(self.json_file, 'r') as f:
                    vulns = f.read()[:10000]
                prompt = f"Review this vulnerability JSON. Identify how these can be chained (e.g., Open Redirect to SSRF). Provide an exploitation strategy: {vulns}"
                chaining = call_gemini(prompt)
                out.write(f"=== Attack Chaining Strategies ===\n{chaining}\n")

        print(f"{Fore.GREEN}[OK] AI Insights saved to {self.ai_file}{Style.RESET_ALL}")

    # ==========================================
    # 🚀 EXECUTION WORKFLOW
    # ==========================================
    def run(self):
        self.show_banner()
        
        if self.doctor:
            print(f"{Fore.CYAN}[*] Running system diagnostics (Doctor Mode)...{Style.RESET_ALL}")
            # Port doctor logic here or call subprocess
            sys.exit(0)
            
        if not self.domain and not self.filename:
            print(f"{Fore.RED}[!] Please provide a target using -d or -f{Style.RESET_ALL}")
            sys.exit(1)

        targets = []
        if self.domain:
            targets.append(self.domain)
        if self.filename:
            with open(self.filename, 'r') as f:
                targets.extend([line.strip() for line in f])

        for target in targets:
            self.recon_and_crawl(target)
            self.run_nuclei_scan()
            self.active_validation()
            self.deep_ai_analysis()

        print(f"\n{Fore.GREEN}======================================")
        print(f"✅ Scan Completed Successfully!")
        print(f"📁 JSON Results : {self.json_file}")
        print(f"🛡️  Proofs Dir  : {self.proofs_dir}")
        if self.ai_mode:
            print(f"🧠 AI Insights  : {self.ai_file}")
        print(f"======================================{Style.RESET_ALL}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("-d", "--domain", help="Single domain to scan")
    parser.add_argument("-f", "--file", help="File containing multiple domains")
    parser.add_argument("--ai", action="store_true", help="Enable AI Deep Context analysis")
    parser.add_argument("--fast", action="store_true", help="Fast scan mode")
    parser.add_argument("--deep", action="store_true", help="Deep scan mode")
    parser.add_argument("--doctor", action="store_true", help="Run system diagnostics")
    parser.add_argument("--update", action="store_true", help="Update tools")
    parser.add_argument("-h", "--help", action="help", default=argparse.SUPPRESS, help="Show this help message and exit")

    args = parser.parse_args()
    
    nf = NucleiFuzzer(args)
    nf.run()
