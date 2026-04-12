#!/usr/bin/env python3

import os
import sys
import json
import shutil
import argparse
import subprocess
import concurrent.futures
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
        self.validate_mode = args.validate
        self.fast_mode = args.fast
        self.deep_mode = args.deep
        
        self.base_dir = Path(__file__).parent.absolute()
        self.output_dir = self.base_dir / "output"
        self.proofs_dir = self.output_dir / "proofs"
        
        # Ensure directories exist
        self.output_dir.mkdir(exist_ok=True)
        self.proofs_dir.mkdir(exist_ok=True)
        
        # Output files
        self.raw_file = self.output_dir / "raw.txt"
        self.validated_file = self.output_dir / "validated.txt"
        self.live_file = self.output_dir / "live.txt"
        self.json_file = self.output_dir / "results.json"
        self.js_file = self.output_dir / "js_endpoints.txt"
        self.ai_file = self.output_dir / "ai_insights.txt"

        # Rate limits
        self.rate_limit = 200 if self.fast_mode else 50

    def show_banner(self):
        banner = f"""{Fore.RED}
███╗   ██╗██╗   ██╗ ██████╗██╗     ███████╗██╗███████╗██╗   ██╗███████╗███████╗███████╗██████╗ 
████╗  ██║██║   ██║██╔════╝██║     ██╔════╝██║██╔════╝██║   ██║╚══███╔╝╚══███╔╝██╔════╝██╔══██╗
██╔██╗ ██║██║   ██║██║     ██║     █████╗  ██║█████╗  ██║   ██║  ███╔╝   ███╔╝ █████╗  ██████╔╝
██║╚██╗██║██║   ██║██║     ██║     ██╔══╝  ██║██╔══╝  ██║   ██║ ███╔╝   ███╔╝  ██╔══╝  ██╔══██╗
██║ ╚████║╚██████╔╝╚██████╗███████╗███████╗██║██║     ╚██████╔╝███████╗███████╗███████╗██║  ██║
╚═╝  ╚═══╝ ╚═════╝  ╚═════╝╚══════╝╚══════╝╚═╝╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
                                               
                                            ⚡ NucleiFuzzer v4.0 (Python Core Engine)
                                               High-Speed Linear Pipeline + AI Validation
{Style.RESET_ALL}"""
        print(banner)

    def run_command(self, cmd, silent=False):
        """Helper to safely run shell commands."""
        try:
            if silent:
                subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                subprocess.run(cmd, shell=True, check=True)
        except subprocess.CalledProcessError:
            if not silent:
                print(f"{Fore.RED}[WARN] Command failed or returned empty: {cmd}{Style.RESET_ALL}")

    # ==========================================
    # 🔍 PHASE 1: PARALLEL RECON
    # ==========================================
    def recon(self, target):
        print(f"\n{Fore.BLUE}[*] PHASE 1: Starting Parallel Recon & URL Collection for {target}...{Style.RESET_ALL}")
        
        # Define the tools we want to run concurrently for maximum speed
        commands = {
            "ParamSpider": f"python3 ~/ParamSpider/paramspider.py -d {target} --quiet -o {self.output_dir}/param.txt",
            "Waybackurls": f"echo {target} | waybackurls > {self.output_dir}/wayback.txt",
            "Gauplus": f"echo {target} | gauplus -subs > {self.output_dir}/gau.txt",
            "Hakrawler": f"echo {target} | hakrawler -d 3 -subs -u > {self.output_dir}/hakrawler.txt",
            "Katana": f"echo {target} | katana -d 3 -silent > {self.output_dir}/katana.txt"
        }

        # Run them in parallel threads
        with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
            futures = {executor.submit(self.run_command, cmd, True): name for name, cmd in commands.items()}
            for future in concurrent.futures.as_completed(futures):
                tool_name = futures[future]
                print(f"{Fore.GREEN}[+] {tool_name} completed.{Style.RESET_ALL}")

        # Merge all collected URLs safely
        print(f"{Fore.CYAN}[*] Merging raw URLs...{Style.RESET_ALL}")
        self.run_command(f"cat {self.output_dir}/*.txt | grep -aE '^https?://' > {self.raw_file}", silent=True)

        # Extract JS files for optional AI Analysis later
        self.run_command(f"grep -aEi '\.js(\?|$)' {self.raw_file} > {self.js_file}", silent=True)

    # ==========================================
    # 🧹 PHASE 2: DEDUP & FILTERING
    # ==========================================
    def dedup(self):
        print(f"\n{Fore.BLUE}[*] PHASE 2: Deduplicating URLs...{Style.RESET_ALL}")
        if not self.raw_file.exists() or self.raw_file.stat().st_size == 0:
            print(f"{Fore.RED}[!] No URLs found during recon. Exiting.{Style.RESET_ALL}")
            sys.exit(1)
            
        self.run_command(f"sort -u {self.raw_file} | uro > {self.validated_file}")
        
        with open(self.validated_file, 'r') as f:
            count = sum(1 for _ in f)
        print(f"{Fore.GREEN}[+] Unique URLs ready for probing: {count}{Style.RESET_ALL}")

    # ==========================================
    # 🌐 PHASE 3: LIVE HOST PROBING
    # ==========================================
    def probe_live(self):
        print(f"\n{Fore.BLUE}[*] PHASE 3: Probing live hosts with httpx...{Style.RESET_ALL}")
        
        cmd = f"httpx -silent -mc 200,204,301,302,401,403,405,500,502,503,504 -l {self.validated_file} -o {self.live_file}"
        self.run_command(cmd, silent=True)
        
        if not self.live_file.exists() or self.live_file.stat().st_size == 0:
            print(f"{Fore.RED}[!] No live hosts found. Exiting.{Style.RESET_ALL}")
            sys.exit(1)

    # ==========================================
    # ⚡ PHASE 4: NUCLEI SCANNING
    # ==========================================
    def nuclei_scan(self):
        print(f"\n{Fore.BLUE}[*] PHASE 4: Running Nuclei DAST Scan (Rate: {self.rate_limit})...{Style.RESET_ALL}")
        template_dir = os.path.expanduser("~/nuclei-templates")
        
        cmd = f"nuclei -l {self.live_file} -t {template_dir} -dast -severity critical,high,medium -rl {self.rate_limit} -jsonl -silent -o {self.json_file}"
        self.run_command(cmd)
        
        print(f"{Fore.GREEN}[+] Nuclei scan complete. Results saved to {self.json_file}{Style.RESET_ALL}")

    # ==========================================
    # 🎯 OPTIONAL: ACTIVE VALIDATION
    # ==========================================
    def active_validation(self):
        if not self.validate_mode:
            return
            
        print(f"\n{Fore.YELLOW}[*] OPTIONAL PHASE: Initializing Active Validation...{Style.RESET_ALL}")
        
        if not self.json_file.exists() or self.json_file.stat().st_size == 0:
            print("[INFO] No vulnerabilities found to validate.")
            return

        with open(self.json_file, 'r') as f:
            findings = [json.loads(line) for line in f if line.strip()]

        # 1. SQLi Validation
        sqli_targets = [f['matched-at'] for f in findings if 'sqli' in f.get('info', {}).get('name', '').lower()]
        if sqli_targets and shutil.which("sqlmap"):
            print(f"{Fore.CYAN}[!] Triggering SQLMap against potential SQLi targets...{Style.RESET_ALL}")
            for target in set(sqli_targets):
                print(f"[*] Attacking: {target}")
                cmd = f"sqlmap -u \"{target}\" --batch --level 1 --risk 1 --dbs --output-dir={self.proofs_dir}/sqlmap"
                self.run_command(cmd, silent=True)
                print(f"{Fore.GREEN}[+] SQLMap execution finished for {target}{Style.RESET_ALL}")

        # 2. XSS Validation
        xss_targets = [f['matched-at'] for f in findings if 'xss' in f.get('info', {}).get('name', '').lower()]
        if xss_targets and shutil.which("dalfox"):
            print(f"{Fore.CYAN}[!] Triggering Dalfox against potential XSS targets...{Style.RESET_ALL}")
            xss_file = self.output_dir / "xss_targets.txt"
            with open(xss_file, 'w') as f:
                f.write("\n".join(set(xss_targets)))
            
            cmd = f"dalfox file {xss_file} -o {self.proofs_dir}/xss_confirmed.txt"
            self.run_command(cmd, silent=True)

    # ==========================================
    # 🧠 OPTIONAL: DEEP AI ANALYSIS
    # ==========================================
    def ai_analysis(self):
        if not self.ai_mode:
            return
            
        print(f"\n{Fore.YELLOW}[*] OPTIONAL PHASE: Running Deep AI Context Analysis...{Style.RESET_ALL}")
        
        gemini_key = os.environ.get("GEMINI_API_KEY")
        if not gemini_key:
            print(f"{Fore.RED}[WARN] GEMINI_API_KEY environment variable not found. Skipping AI.{Style.RESET_ALL}")
            return

        import requests
        
        def ask_gemini(prompt):
            url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={gemini_key}"
            headers = {'Content-Type': 'application/json'}
            data = {"contents": [{"parts": [{"text": prompt}]}]}
            try:
                response = requests.post(url, headers=headers, json=data)
                return response.json()['candidates'][0]['content']['parts'][0]['text']
            except Exception as e:
                return f"AI API Error: {str(e)}"

        with open(self.ai_file, 'w') as out:
            out.write("=== 🧠 NUCLEIFUZZER DEEP AI INSIGHTS ===\n\n")

            # Extract business logic from JS
            if self.js_file.exists() and self.js_file.stat().st_size > 0:
                print(f"{Fore.CYAN}[*] Extracting logic from top JavaScript files...{Style.RESET_ALL}")
                with open(self.js_file, 'r') as f:
                    js_urls = [line.strip() for line in f.readlines()[:3]] 
                
                for url in js_urls:
                    try:
                        js_content = requests.get(url, timeout=5).text[:8000]
                        prompt = f"Read this JS. Extract hidden API endpoints and secrets as a bulleted list. Code: {js_content}"
                        out.write(f"[*] Findings for {url}:\n{ask_gemini(prompt)}\n\n")
                    except:
                        pass

            # Vulnerability Chaining
            if self.json_file.exists() and self.json_file.stat().st_size > 0:
                print(f"{Fore.CYAN}[*] Generating Exploit Chains from Nuclei results...{Style.RESET_ALL}")
                with open(self.json_file, 'r') as f:
                    vulns = f.read()[:10000]
                prompt = f"Review this vulnerability JSON. Identify how these can be chained. Provide an exploitation strategy: {vulns}"
                out.write(f"=== Exploit Chaining Strategies ===\n{ask_gemini(prompt)}\n")

        print(f"{Fore.GREEN}[+] AI Insights saved to {self.ai_file}{Style.RESET_ALL}")

    # ==========================================
    # 🚀 ORCHESTRATOR EXECUTION
    # ==========================================
    def run(self):
        self.show_banner()
        
        targets = []
        if self.domain:
            targets.append(self.domain)
        if self.filename:
            with open(self.filename, 'r') as f:
                targets.extend([line.strip() for line in f if line.strip()])

        if not targets:
            print(f"{Fore.RED}[!] Please provide a target using -d or -f{Style.RESET_ALL}")
            sys.exit(1)

        # Main Pipeline Loop
        for target in targets:
            self.recon(target)
            self.dedup()
            self.probe_live()
            self.nuclei_scan()
            
            # Optional Modules
            self.active_validation()
            self.ai_analysis()

        print(f"\n{Fore.GREEN}======================================")
        print(f"✅ Pipeline Completed Successfully!")
        print(f"📁 JSON Results  : {self.json_file}")
        if self.validate_mode:
            print(f"🛡️  Proofs Dir   : {self.proofs_dir}")
        if self.ai_mode:
            print(f"🧠 AI Insights   : {self.ai_file}")
        print(f"======================================{Style.RESET_ALL}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="NucleiFuzzer AI Python Orchestrator", add_help=False)
    
    # Core Arguments
    parser.add_argument("-d", "--domain", help="Single domain to scan")
    parser.add_argument("-f", "--file", help="File containing multiple domains")
    parser.add_argument("--fast", action="store_true", help="Enable fast scanning mode (higher rate limits)")
    parser.add_argument("--deep", action="store_true", help="Enable deep scanning mode (lower rate limits)")
    
    # Advanced / Next-Gen Arguments
    parser.add_argument("--validate", action="store_true", help="Enable Active Validation (SQLMap, Dalfox)")
    parser.add_argument("--ai", action="store_true", help="Enable Deep Context AI Analysis (Requires GEMINI_API_KEY)")
    
    parser.add_argument("-h", "--help", action="help", default=argparse.SUPPRESS, help="Show this help message and exit")

    args = parser.parse_args()
    
    nf = NucleiFuzzer(args)
    nf.run()
