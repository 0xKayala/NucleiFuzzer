#!/usr/bin/env python3

# ==============================================================================
# 📦 SECTION 1: SYSTEM IMPORTS
# These libraries provide basic system functions like file handling, 
# running terminal commands, and managing dates/times.
# ==============================================================================
import os
import sys
import json
import shutil
import argparse
import subprocess
import html
import concurrent.futures
from datetime import datetime
from pathlib import Path
from colorama import init, Fore, Style

# Initialize colorama for cross-platform color support in the terminal
init(autoreset=True)

# ==============================================================================
# 🚀 SECTION 2: THE CORE ENGINE CLASS
# This class contains all the logic for recon, scanning, and AI analysis.
# ==============================================================================
class NucleiFuzzer:
    def __init__(self, args):
        """
        INITIALIZATION: 
        Sets up the folders, file paths, and scan settings based on your input.
        """
        self.domain = args.domain
        self.filename = args.file
        self.ai_mode = args.ai
        self.validate_mode = args.validate
        self.fast_mode = args.fast
        self.deep_mode = args.deep
        self.doctor_mode = args.doctor
        self.update_mode = args.update
        
        # Path configuration (Uses your current folder to save results)
        self.base_dir = Path.cwd()
        self.output_dir = self.base_dir / "output"
        self.proofs_dir = self.output_dir / "proofs"
        
        # Create folders unless just running a check or update
        if not self.doctor_mode and not self.update_mode:
            self.output_dir.mkdir(exist_ok=True)
            self.proofs_dir.mkdir(exist_ok=True)
        
        # Define standard file names for results
        self.raw_file = self.output_dir / "raw.txt"
        self.validated_file = self.output_dir / "validated.txt"
        self.live_file = self.output_dir / "live.txt"
        self.json_file = self.output_dir / "results.json"
        self.html_file = self.output_dir / "report.html"
        self.js_file = self.output_dir / "js_endpoints.txt"
        self.ai_file = self.output_dir / "ai_insights.txt"
        self.dns_file = self.output_dir / "dns_intel.txt"

        # Scanning speed (Rate Limit)
        self.rate_limit = 200 if self.fast_mode else 50

    # --------------------------------------------------------------------------
    # 🎨 FUNCTION: show_banner
    # Displays the ASCII art and version info when the tool starts.
    # --------------------------------------------------------------------------
    def show_banner(self):
        banner = f"""{Fore.RED}
███╗   ██╗██╗   ██╗ ██████╗██╗     ███████╗██╗███████╗██╗   ██╗███████╗███████╗███████╗██████╗ 
████╗  ██║██║   ██║██╔════╝██║     ██╔════╝██║██╔════╝██║   ██║╚══███╔╝╚══███╔╝██╔════╝██╔══██╗
██╔██╗ ██║██║   ██║██║     ██║     █████╗  ██║█████╗  ██║   ██║  ███╔╝   ███╔╝ █████╗  ██████╔╝
██║╚██╗██║██║   ██║██║     ██║     ██╔══╝  ██║██╔══╝  ██║   ██║ ███╔╝   ███╔╝  ██╔══╝  ██╔══██╗
██║ ╚████║╚██████╔╝╚██████╗███████╗███████╗██║██║     ╚██████╔╝███████╗███████╗███████╗██║  ██║
╚═╝  ╚═══╝ ╚═════╝  ╚═════╝╚══════╝╚══════╝╚═╝╚═╝      ╚═════╝ ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
                                               
                                            ⚡ NucleiFuzzer v4.0 (Python Core Engine)
                                               High-Speed Pipeline + AI Validation
{Style.RESET_ALL}"""
        print(banner)

    # --------------------------------------------------------------------------
    # 💻 FUNCTION: run_command
    # Safely executes terminal commands (like nuclei or katana) from Python.
    # --------------------------------------------------------------------------
    def run_command(self, cmd, silent=False):
        try:
            if silent:
                subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            else:
                subprocess.run(cmd, shell=True, check=True)
        except subprocess.CalledProcessError:
            if not silent:
                print(f"{Fore.RED}[WARN] Command failed: {cmd}{Style.RESET_ALL}")

    # --------------------------------------------------------------------------
    # 🩺 FUNCTION: run_doctor
    # Checks if all required hacking tools and API keys are present.
    # --------------------------------------------------------------------------
    def run_doctor(self):
        print(f"\n{Fore.CYAN}======================================")
        print(f"🩺 NucleiFuzzer Diagnostics (Doctor Mode)")
        print(f"======================================{Style.RESET_ALL}\n")
        
        tools = ["python3", "pip3", "go", "nuclei", "httpx", "katana", "waybackurls", "gauplus", "hakrawler", "uro", "sqlmap", "dalfox", "subpipe"]
        issues = 0
        
        for tool in tools:
            if shutil.which(tool):
                print(f"{Fore.GREEN}[OK] {tool} is installed.{Style.RESET_ALL}")
            else:
                print(f"{Fore.RED}[FAIL] {tool} is missing.{Style.RESET_ALL}")
                issues += 1
                
        print("\n[*] Checking Environment Variables...")
        for var in ["GEMINI_API_KEY", "SUBPIPE_API_KEY"]:
            if os.environ.get(var):
                print(f"{Fore.GREEN}[OK] {var} is configured.{Style.RESET_ALL}")
            else:
                print(f"{Fore.YELLOW}[WARN] {var} is missing. Related features will be skipped.{Style.RESET_ALL}")

        print(f"\n{Fore.CYAN}======================================")
        if issues == 0:
            print(f"{Fore.GREEN}✅ System is 100% ready.{Style.RESET_ALL}")
        else:
            print(f"{Fore.YELLOW}⚠️  Found {issues} missing dependencies. Run with --update to install tools.{Style.RESET_ALL}")
        print(f"{Fore.CYAN}======================================{Style.RESET_ALL}")
        sys.exit(0)

    # --------------------------------------------------------------------------
    # ⬆️ FUNCTION: run_update
    # SMART INSTALLER: Only downloads and installs tools you don't have yet.
    # --------------------------------------------------------------------------
    def run_update(self):
        print(f"\n{Fore.CYAN}======================================")
        print(f"⬆️  NucleiFuzzer Smart Installer & Updater")
        print(f"======================================{Style.RESET_ALL}\n")
        
        if not shutil.which("go"):
            print(f"{Fore.RED}[!] Go is not installed. Please install Golang first.{Style.RESET_ALL}")
            sys.exit(1)

        go_tools = {
            "nuclei": "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest",
            "httpx": "github.com/projectdiscovery/httpx/cmd/httpx@latest",
            "katana": "github.com/projectdiscovery/katana/cmd/katana@latest",
            "waybackurls": "github.com/tomnomnom/waybackurls@latest",
            "gauplus": "github.com/bp0lr/gauplus@latest",
            "hakrawler": "github.com/hakluke/hakrawler@latest",
            "dalfox": "github.com/hahwul/dalfox/v2@latest",
            "subpipe": "github.com/anshumanpattnaik/subpipe@latest"
        }

        installed_any = False
        print(f"{Fore.BLUE}[*] Checking and installing missing tools...{Style.RESET_ALL}")
        
        for tool, path in go_tools.items():
            if not shutil.which(tool):
                print(f"{Fore.YELLOW}[!] {tool} is missing. Installing...{Style.RESET_ALL}")
                self.run_command(f"go install -v {path}", silent=True)
                installed_any = True
            else:
                print(f"{Fore.GREEN}[OK] {tool} is already installed.{Style.RESET_ALL}")

        # Check for sqlmap (Linux system package)
        if not shutil.which("sqlmap"):
            print(f"{Fore.YELLOW}[!] sqlmap is missing. Installing via apt...{Style.RESET_ALL}")
            self.run_command("sudo apt-get update && sudo apt-get install sqlmap -y", silent=True)
            installed_any = True

        # Check for ParamSpider (GitHub repository)
        param_path = os.path.expanduser("~/ParamSpider")
        if not os.path.exists(param_path):
            print(f"{Fore.YELLOW}[!] ParamSpider is missing. Cloning repository...{Style.RESET_ALL}")
            self.run_command(f"git clone https://github.com/0xKayala/ParamSpider {param_path}", silent=True)
            installed_any = True

        # Update Nuclei templates
        self.run_command("nuclei -update-templates", silent=True)
        print(f"\n{Fore.GREEN}✅ Smart update complete. System is ready.{Style.RESET_ALL}")
        sys.exit(0)

    # --------------------------------------------------------------------------
    # 🔍 FUNCTION: recon (PHASE 1)
    # Starts all reconnaissance tools at the same time for maximum speed.
    # --------------------------------------------------------------------------
    def recon(self, target):
        print(f"\n{Fore.BLUE}[*] PHASE 1: Starting Parallel Recon & URL Collection for {target}...{Style.RESET_ALL}")
        commands = {
            "ParamSpider": f"python3 ~/ParamSpider/paramspider.py -d {target} --quiet -o {self.output_dir}/param.txt",
            "Waybackurls": f"echo {target} | waybackurls > {self.output_dir}/wayback.txt",
            "Gauplus": f"echo {target} | gauplus -subs > {self.output_dir}/gau.txt",
            "Hakrawler": f"echo {target} | hakrawler -d 3 -subs -u > {self.output_dir}/hakrawler.txt",
            "Katana": f"echo {target} | katana -d 3 -silent > {self.output_dir}/katana.txt"
        }

        # Multi-threading: Runs all 5 tools above simultaneously
        with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
            futures = {executor.submit(self.run_command, cmd, True): name for name, cmd in commands.items()}
            for future in concurrent.futures.as_completed(futures):
                print(f"{Fore.GREEN}[+] {futures[future]} completed.{Style.RESET_ALL}")

        # Merge results into one file
        self.run_command(f"cat {self.output_dir}/*.txt | grep -aE '^https?://' > {self.raw_file}", silent=True)
        # Use Raw String (rf"") to prevent regex escape warnings
        self.run_command(rf"grep -aEi '\.js(\?|$)' {self.raw_file} > {self.js_file}", silent=True)

    # --------------------------------------------------------------------------
    # 🧹 FUNCTION: dedup (PHASE 2)
    # Removes all duplicate URLs to keep the scan focused.
    # --------------------------------------------------------------------------
    def dedup(self):
        print(f"\n{Fore.BLUE}[*] PHASE 2: Deduplicating URLs...{Style.RESET_ALL}")
        if not self.raw_file.exists() or self.raw_file.stat().st_size == 0:
            print(f"{Fore.RED}[!] No URLs found during recon. Exiting.{Style.RESET_ALL}")
            sys.exit(1)
        self.run_command(f"sort -u {self.raw_file} | uro > {self.validated_file}")

    # --------------------------------------------------------------------------
    # 🌐 FUNCTION: dns_intel (PHASE 3)
    # Runs the SubPipe tool to look for DNS-based vulnerabilities.
    # --------------------------------------------------------------------------
    def dns_intel(self):
        if not os.environ.get("SUBPIPE_API_KEY") or not shutil.which("subpipe"):
            return
        print(f"\n{Fore.BLUE}[*] PHASE 3: Running DNS Intelligence (SubPipe)...{Style.RESET_ALL}")
        self.run_command(f"cat {self.validated_file} | subpipe > {self.dns_file}", silent=True)
        if self.dns_file.exists() and self.dns_file.stat().st_size > 0:
            print(f"{Fore.GREEN}[+] DNS issues detected: {self.dns_file}{Style.RESET_ALL}")

    # --------------------------------------------------------------------------
    # 📡 FUNCTION: probe_live (PHASE 4)
    # Uses httpx to verify which URLs are actually online and responding.
    # --------------------------------------------------------------------------
    def probe_live(self):
        print(f"\n{Fore.BLUE}[*] PHASE 4: Probing live hosts with httpx...{Style.RESET_ALL}")
        cmd = f"httpx -silent -mc 200,204,301,302,401,403,405,500,502,503,504 -l {self.validated_file} -o {self.live_file}"
        self.run_command(cmd, silent=True)
        
        # Fallback: If httpx drops everything (Cloud Shell issue), use validated file
        if not self.live_file.exists() or self.live_file.stat().st_size == 0:
            print(f"{Fore.YELLOW}[WARN] No live hosts found. Bypassing httpx filter.{Style.RESET_ALL}")
            shutil.copy(self.validated_file, self.live_file)

    # --------------------------------------------------------------------------
    # ⚡ FUNCTION: nuclei_scan (PHASE 5)
    # Fires the Nuclei scanner with fuzzing templates at the live targets.
    # --------------------------------------------------------------------------
    def nuclei_scan(self):
        print(f"\n{Fore.BLUE}[*] PHASE 5: Running Nuclei DAST Scan (Rate: {self.rate_limit})...{Style.RESET_ALL}")
        templates = os.path.expanduser("~/nuclei-templates")
        cmd = f"nuclei -l {self.live_file} -t {templates} -dast -severity critical,high,medium,low -rl {self.rate_limit} -jsonl -silent -o {self.json_file}"
        self.run_command(cmd)

    # --------------------------------------------------------------------------
    # 📊 FUNCTION: generate_html_report
    # Converts the raw JSON data into a beautiful, dark-themed HTML file.
    # --------------------------------------------------------------------------
    def generate_html_report(self):
        if not self.json_file.exists() or self.json_file.stat().st_size == 0:
            return
        print(f"\n{Fore.CYAN}[*] Generating HTML Report...{Style.RESET_ALL}")
        findings = []
        counts = {"critical": 0, "high": 0, "medium": 0, "low": 0}
        
        with open(self.json_file, 'r') as f:
            for line in f:
                if line.strip():
                    try:
                        d = json.loads(line)
                        findings.append(d)
                        s = d.get('info', {}).get('severity', 'low').lower()
                        if s in counts: counts[s] += 1
                    except: pass
        
        # Sort findings by severity (Critical first)
        sev_order = {"critical": 0, "high": 1, "medium": 2, "low": 3, "info": 4}
        findings.sort(key=lambda x: sev_order.get(x.get('info', {}).get('severity', 'low').lower(), 5))

        # HTML Styling and Template
        html_tpl = f"""<!DOCTYPE html><html><head><title>NucleiFuzzer Results</title>
        <style>
            body {{ background: #121212; color: #e0e0e0; font-family: 'Segoe UI', sans-serif; padding: 40px; }}
            .summary {{ display: flex; gap: 20px; margin-bottom: 30px; }}
            .box {{ background: #1e1e1e; padding: 15px 30px; border-radius: 8px; text-align: center; min-width: 100px; border-left: 5px solid #333; }}
            .critical {{ border-color: #ff4444; color: #ff4444; }} 
            .high {{ border-color: #ff8800; color: #ff8800; }}
            .medium {{ border-color: #ffcc00; color: #ffcc00; }}
            .low {{ border-color: #00ccff; color: #00ccff; }}
            table {{ width: 100%; border-collapse: collapse; background: #1e1e1e; border-radius: 8px; overflow: hidden; }}
            th, td {{ padding: 12px; border-bottom: 1px solid #333; text-align: left; }}
            th {{ background: #2d2d2d; color: #00ffcc; }}
            a {{ color: #00ffcc; text-decoration: none; }}
        </style></head><body>
        <h1>⚡ NucleiFuzzer V4.0 Report</h1>
        <div class="summary">
            <div class="box critical"><h3>Critical</h3><h2>{counts['critical']}</h2></div>
            <div class="box high"><h3>High</h3><h2>{counts['high']}</h2></div>
            <div class="box medium"><h3>Medium</h3><h2>{counts['medium']}</h2></div>
            <div class="box low"><h3>Low</h3><h2>{counts['low']}</h2></div>
        </div>
        <table><tr><th>Severity</th><th>Vulnerability</th><th>Target URL</th></tr>"""
        
        for f in findings:
            s = f.get('info', {}).get('severity', 'low').lower()
            n = html.escape(f.get('info', {}).get('name', 'Unknown'))
            u = html.escape(f.get('matched-at', ''))
            html_tpl += f"<tr><td class='{s}'><b>{s.upper()}</b></td><td>{n}</td><td><a href='{u}' target='_blank'>{u}</a></td></tr>"
        
        with open(self.html_file, 'w') as f: 
            f.write(html_tpl + "</table></body></html>")

    # --------------------------------------------------------------------------
    # 🎯 FUNCTION: active_validation
    # Automatically triggers sqlmap or dalfox to PROVE the vulnerabilities found.
    # --------------------------------------------------------------------------
    def active_validation(self):
        if not self.validate_mode or not self.json_file.exists() or self.json_file.stat().st_size == 0:
            return
        print(f"\n{Fore.YELLOW}[*] OPTIONAL PHASE: Initializing Active Validation (sqlmap/dalfox)...{Style.RESET_ALL}")
        with open(self.json_file, 'r') as f:
            v = [json.loads(l) for l in f if l.strip()]

        # Proof for SQLi
        sqli = [x['matched-at'] for x in v if 'sqli' in x.get('info', {}).get('name', '').lower()]
        if sqli and shutil.which("sqlmap"):
            for t in set(sqli): 
                self.run_command(f"sqlmap -u \"{t}\" --batch --level 1 --risk 1 --dbs --output-dir={self.proofs_dir}/sqlmap", silent=True)

        # Proof for XSS
        xss = [x['matched-at'] for x in v if 'xss' in x.get('info', {}).get('name', '').lower()]
        if xss and shutil.which("dalfox"):
            xf = self.output_dir / "xss_targets.txt"
            with open(xf, 'w') as f: f.write("\n".join(set(xss)))
            self.run_command(f"dalfox file {xf} -o {self.proofs_dir}/xss_confirmed.txt", silent=True)

    # --------------------------------------------------------------------------
    # 🧠 FUNCTION: ai_analysis
    # Sends data to Google Gemini AI to find logic flaws and chain exploits.
    # --------------------------------------------------------------------------
    def ai_analysis(self):
        if not self.ai_mode or not os.environ.get("GEMINI_API_KEY"):
            return
        print(f"\n{Fore.YELLOW}[*] OPTIONAL PHASE: Running Deep AI Context Analysis (Gemini)...{Style.RESET_ALL}")
        import requests
        key = os.environ["GEMINI_API_KEY"]
        
        def ask_gemini(prompt):
            try:
                r = requests.post(f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={key}", 
                                  json={"contents": [{"parts": [{"text": prompt}]}]})
                data = r.json()
                if 'error' in data: return f"API Error: {data['error'].get('message')}"
                if 'candidates' not in data or not data['candidates']: return "Blocked by Safety Filter"
                return data['candidates'][0]['content']['parts'][0]['text']
            except: return "AI Request Failed"

        with open(self.ai_file, 'w') as out:
            out.write(f"=== 🧠 AI SECURITY INSIGHTS ({datetime.now()}) ===\n\n")
            
            # Phase 1: JS Logic
            if self.js_file.exists():
                with open(self.js_file, 'r') as f:
                    for url in [l.strip() for l in f.readlines()[:3]]:
                        try:
                            js = requests.get(url, timeout=5).text[:8000]
                            out.write(f"[*] JS Findings for {url}:\n{ask_gemini(f'Extract hidden endpoints/secrets from JS: {js}')}\n\n")
                        except: pass
            
            # Phase 2: Chaining
            if self.json_file.exists():
                with open(self.json_file, 'r') as f:
                    out.write(f"=== Exploit Chaining Strategies ===\n{ask_gemini(f'Chain these vulnerabilities: {f.read()[:8000]}')}\n")
        print(f"{Fore.GREEN}[+] AI Analysis saved to {self.ai_file}{Style.RESET_ALL}")

    # --------------------------------------------------------------------------
    # 🚀 FUNCTION: run
    # THE MASTER ORCHESTRATOR: Controls the order of everything.
    # --------------------------------------------------------------------------
    def run(self):
        self.show_banner()
        if self.doctor_mode: self.run_doctor()
        if self.update_mode: self.run_update()
        
        # Load targets from -d (domain) or -f (file)
        targets = [self.domain] if self.domain else []
        if self.filename:
            with open(self.filename, 'r') as f: targets.extend([l.strip() for l in f if l.strip()])
        if not targets: sys.exit(f"{Fore.RED}[!] No target provided.{Style.RESET_ALL}")

        # Loop through every domain provided
        for t in targets:
            self.recon(t)
            self.dedup()
            self.dns_intel()
            self.probe_live()
            self.nuclei_scan()
            self.generate_html_report()
            self.active_validation()
            self.ai_analysis()
            
        print(f"\n{Fore.GREEN}✅ Pipeline Complete. Results in {self.output_dir}{Style.RESET_ALL}")

# ==============================================================================
# 🛠️ SECTION 3: ARGUMENT PARSING
# This part defines the flags (like -d, -f, --ai) that you type in the terminal.
# ==============================================================================
if __name__ == "__main__":
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("-d", "--domain", help="Single domain to scan")
    parser.add_argument("-f", "--file", help="File containing multiple domains")
    parser.add_argument("--fast", action="store_true", help="Fast scan mode")
    parser.add_argument("--deep", action="store_true", help="Deep scan mode")
    parser.add_argument("--validate", action="store_true", help="Enable Active Validation")
    parser.add_argument("--ai", action="store_true", help="Enable Deep AI Analysis")
    parser.add_argument("--doctor", action="store_true", help="Run diagnostics")
    parser.add_argument("--update", action="store_true", help="Update tools")
    parser.add_argument("-h", "--help", action="help", default=argparse.SUPPRESS)
    
    # Start the engine!
    NucleiFuzzer(parser.parse_args()).run()
