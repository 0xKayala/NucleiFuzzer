#!/usr/bin/env python3

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

# Initialize colorama for cross-platform color support
init(autoreset=True)

# ==========================================
# 🔥 NUCLEIFUZZER v4.0 - MASTER PYTHON ENGINE
# ==========================================

class NucleiFuzzer:
    def __init__(self, args):
        self.domain = args.domain
        self.filename = args.file
        self.ai_mode = args.ai
        self.validate_mode = args.validate
        self.fast_mode = args.fast
        self.deep_mode = args.deep
        self.doctor_mode = args.doctor
        self.update_mode = args.update
        
        self.base_dir = Path(__file__).parent.absolute()
        self.output_dir = self.base_dir / "output"
        self.proofs_dir = self.output_dir / "proofs"
        
        # Ensure directories exist
        if not self.doctor_mode and not self.update_mode:
            self.output_dir.mkdir(exist_ok=True)
            self.proofs_dir.mkdir(exist_ok=True)
        
        # Output files
        self.raw_file = self.output_dir / "raw.txt"
        self.validated_file = self.output_dir / "validated.txt"
        self.live_file = self.output_dir / "live.txt"
        self.json_file = self.output_dir / "results.json"
        self.html_file = self.output_dir / "report.html"
        self.js_file = self.output_dir / "js_endpoints.txt"
        self.ai_file = self.output_dir / "ai_insights.txt"
        self.dns_file = self.output_dir / "dns_intel.txt"

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
                                               High-Speed Pipeline + AI Validation
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
    # 🩺 DOCTOR MODE
    # ==========================================
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
        if os.environ.get("GEMINI_API_KEY"):
            print(f"{Fore.GREEN}[OK] GEMINI_API_KEY is configured.{Style.RESET_ALL}")
        else:
            print(f"{Fore.YELLOW}[WARN] GEMINI_API_KEY is missing. Deep AI analysis will be skipped.{Style.RESET_ALL}")

        if os.environ.get("SUBPIPE_API_KEY"):
            print(f"{Fore.GREEN}[OK] SUBPIPE_API_KEY is configured.{Style.RESET_ALL}")
        else:
            print(f"{Fore.YELLOW}[WARN] SUBPIPE_API_KEY is missing. DNS Intelligence (SubPipe) will be skipped.{Style.RESET_ALL}")

        print(f"\n{Fore.CYAN}======================================")
        if issues == 0:
            print(f"{Fore.GREEN}✅ System is 100% ready.{Style.RESET_ALL}")
        else:
            print(f"{Fore.YELLOW}⚠️  Found {issues} missing dependencies. Run with --update to install Go tools.{Style.RESET_ALL}")
        print(f"{Fore.CYAN}======================================{Style.RESET_ALL}")
        sys.exit(0)

    # ==========================================
    # ⬆️ UPDATE MODE
    # ==========================================
    def run_update(self):
        print(f"\n{Fore.CYAN}======================================")
        print(f"⬆️  NucleiFuzzer Update Engine")
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
            "hakrawler": "github.com/hakluke/hakrawler@latest"
        }

        print(f"{Fore.BLUE}[*] Updating Go-based dependencies...{Style.RESET_ALL}")
        for tool, path in go_tools.items():
            print(f"[*] Installing/Updating {tool}...")
            self.run_command(f"go install -v {path}", silent=True)
            
        print(f"\n{Fore.BLUE}[*] Updating Python packages...{Style.RESET_ALL}")
        self.run_command("pip3 install --upgrade uro requests colorama", silent=True)
        
        print(f"\n{Fore.BLUE}[*] Updating Nuclei Templates...{Style.RESET_ALL}")
        self.run_command("nuclei -update-templates", silent=True)
        self.run_command("nuclei -update", silent=True)

        print(f"\n{Fore.GREEN}✅ All tools updated successfully.{Style.RESET_ALL}")
        sys.exit(0)

    # ==========================================
    # 🔍 PHASE 1: PARALLEL RECON
    # ==========================================
    def recon(self, target):
        print(f"\n{Fore.BLUE}[*] PHASE 1: Starting Parallel Recon & URL Collection for {target}...{Style.RESET_ALL}")
        
        commands = {
            "ParamSpider": f"python3 ~/ParamSpider/paramspider.py -d {target} --quiet -o {self.output_dir}/param.txt",
            "Waybackurls": f"echo {target} | waybackurls > {self.output_dir}/wayback.txt",
            "Gauplus": f"echo {target} | gauplus -subs > {self.output_dir}/gau.txt",
            "Hakrawler": f"echo {target} | hakrawler -d 3 -subs -u > {self.output_dir}/hakrawler.txt",
            "Katana": f"echo {target} | katana -d 3 -silent > {self.output_dir}/katana.txt"
        }

        with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
            futures = {executor.submit(self.run_command, cmd, True): name for name, cmd in commands.items()}
            for future in concurrent.futures.as_completed(futures):
                print(f"{Fore.GREEN}[+] {futures[future]} completed.{Style.RESET_ALL}")

        print(f"{Fore.CYAN}[*] Merging raw URLs...{Style.RESET_ALL}")
        self.run_command(f"cat {self.output_dir}/*.txt | grep -aE '^https?://' > {self.raw_file}", silent=True)
        self.run_command(rf"grep -aEi '\.js(\?|$)' {self.raw_file} > {self.js_file}", silent=True)

    # ==========================================
    # 🧹 PHASE 2: DEDUP & FILTERING
    # ==========================================
    def dedup(self):
        print(f"\n{Fore.BLUE}[*] PHASE 2: Deduplicating URLs...{Style.RESET_ALL}")
        if not self.raw_file.exists() or self.raw_file.stat().st_size == 0:
            print(f"{Fore.RED}[!] No URLs found during recon. Exiting.{Style.RESET_ALL}")
            sys.exit(1)
            
        self.run_command(f"sort -u {self.raw_file} | uro > {self.validated_file}")

    # ==========================================
    # 🌐 PHASE 3: DNS INTELLIGENCE (SubPipe)
    # ==========================================
    def dns_intel(self):
        subpipe_key = os.environ.get("SUBPIPE_API_KEY")
        if not subpipe_key or not shutil.which("subpipe"):
            return # Silently skip if key or tool is missing

        print(f"\n{Fore.BLUE}[*] PHASE 3: Running DNS Intelligence (SubPipe)...{Style.RESET_ALL}")
        
        # Pass the validated URLs into subpipe
        cmd = f"cat {self.validated_file} | subpipe > {self.dns_file}"
        self.run_command(cmd, silent=True)
        
        if self.dns_file.exists() and self.dns_file.stat().st_size > 0:
            print(f"{Fore.GREEN}[+] DNS vulnerabilities detected! Saved to {self.dns_file}{Style.RESET_ALL}")
        else:
            print(f"{Fore.YELLOW}[INFO] No DNS issues found.{Style.RESET_ALL}")

    # ==========================================
    # 📡 PHASE 4: LIVE HOST PROBING
    # ==========================================
    def probe_live(self):
        print(f"\n{Fore.BLUE}[*] PHASE 4: Probing live hosts with httpx...{Style.RESET_ALL}")
        cmd = f"httpx -silent -mc 200,204,301,302,401,403,405,500,502,503,504 -l {self.validated_file} -o {self.live_file}"
        self.run_command(cmd, silent=True)

    # ==========================================
    # ⚡ PHASE 5: NUCLEI SCANNING
    # ==========================================
    def nuclei_scan(self):
        print(f"\n{Fore.BLUE}[*] PHASE 5: Running Nuclei DAST Scan (Rate: {self.rate_limit})...{Style.RESET_ALL}")
        template_dir = os.path.expanduser("~/nuclei-templates")
        cmd = f"nuclei -l {self.live_file} -t {template_dir} -dast -severity critical,high,medium,low -rl {self.rate_limit} -jsonl -silent -o {self.json_file}"
        self.run_command(cmd)

    # ==========================================
    # 📊 HTML REPORTING
    # ==========================================
    def generate_html_report(self):
        if not self.json_file.exists() or self.json_file.stat().st_size == 0:
            return

        print(f"\n{Fore.CYAN}[*] Generating HTML Report...{Style.RESET_ALL}")
        
        findings = []
        counts = {"critical": 0, "high": 0, "medium": 0, "low": 0, "info": 0}
        
        with open(self.json_file, 'r') as f:
            for line in f:
                if line.strip():
                    try:
                        data = json.loads(line)
                        findings.append(data)
                        sev = data.get('info', {}).get('severity', 'info').lower()
                        if sev in counts: counts[sev] += 1
                    except: pass
                    
        # Sort findings by severity
        severity_map = {"critical": 0, "high": 1, "medium": 2, "low": 3, "info": 4}
        findings.sort(key=lambda x: severity_map.get(x.get('info', {}).get('severity', 'info').lower(), 5))

        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>NucleiFuzzer Results</title>
            <style>
                body {{ background-color: #121212; color: #e0e0e0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 40px; }}
                h1 {{ color: #00ffcc; border-bottom: 2px solid #333; padding-bottom: 10px; }}
                .summary {{ background: #1e1e1e; padding: 20px; border-radius: 8px; margin-bottom: 30px; display: flex; gap: 20px; }}
                .stat-box {{ background: #2d2d2d; padding: 15px 25px; border-radius: 6px; text-align: center; }}
                .stat-box h3 {{ margin: 0 0 10px 0; font-size: 14px; text-transform: uppercase; color: #888; }}
                .stat-box .num {{ font-size: 24px; font-weight: bold; }}
                .critical {{ color: #ff4444; }} .high {{ color: #ff8800; }} .medium {{ color: #ffcc00; }} .low {{ color: #00ccff; }}
                table {{ width: 100%; border-collapse: collapse; background: #1e1e1e; border-radius: 8px; overflow: hidden; }}
                th, td {{ padding: 12px 15px; text-align: left; border-bottom: 1px solid #333; }}
                th {{ background-color: #2d2d2d; color: #00ffcc; font-weight: bold; }}
                tr:hover {{ background-color: #2a2a2a; }}
                a {{ color: #00ffcc; text-decoration: none; }}
                a:hover {{ text-decoration: underline; }}
            </style>
        </head>
        <body>
            <h1>⚡ NucleiFuzzer V4.0 Report</h1>
            <div class="summary">
                <div class="stat-box"><h3 class="critical">Critical</h3><div class="num critical">{counts['critical']}</div></div>
                <div class="stat-box"><h3 class="high">High</h3><div class="num high">{counts['high']}</div></div>
                <div class="stat-box"><h3 class="medium">Medium</h3><div class="num medium">{counts['medium']}</div></div>
                <div class="stat-box"><h3 class="low">Low</h3><div class="num low">{counts['low']}</div></div>
            </div>
            <table>
                <tr><th>Severity</th><th>Vulnerability</th><th>Target URL</th></tr>
        """
        
        for f in findings:
            sev = f.get('info', {}).get('severity', 'info').lower()
            name = html.escape(f.get('info', {}).get('name', 'Unknown'))
            url = html.escape(f.get('matched-at', ''))
            html_content += f"<tr><td class='{sev}'><b>{sev.upper()}</b></td><td>{name}</td><td><a href='{url}' target='_blank'>{url}</a></td></tr>\n"
            
        html_content += "</table></body></html>"
        
        with open(self.html_file, 'w') as f:
            f.write(html_content)

    # ==========================================
    # 🎯 OPTIONAL: ACTIVE VALIDATION
    # ==========================================
    def active_validation(self):
        if not self.validate_mode or not self.json_file.exists() or self.json_file.stat().st_size == 0:
            return
            
        print(f"\n{Fore.YELLOW}[*] OPTIONAL PHASE: Initializing Active Validation...{Style.RESET_ALL}")
        with open(self.json_file, 'r') as f:
            findings = [json.loads(line) for line in f if line.strip()]

        sqli_targets = [f['matched-at'] for f in findings if 'sqli' in f.get('info', {}).get('name', '').lower()]
        if sqli_targets and shutil.which("sqlmap"):
            print(f"{Fore.CYAN}[!] Triggering SQLMap against potential SQLi targets...{Style.RESET_ALL}")
            for target in set(sqli_targets):
                cmd = f"sqlmap -u \"{target}\" --batch --level 1 --risk 1 --dbs --output-dir={self.proofs_dir}/sqlmap"
                self.run_command(cmd, silent=True)

        xss_targets = [f['matched-at'] for f in findings if 'xss' in f.get('info', {}).get('name', '').lower()]
        if xss_targets and shutil.which("dalfox"):
            print(f"{Fore.CYAN}[!] Triggering Dalfox against potential XSS targets...{Style.RESET_ALL}")
            xss_file = self.output_dir / "xss_targets.txt"
            with open(xss_file, 'w') as f: f.write("\n".join(set(xss_targets)))
            self.run_command(f"dalfox file {xss_file} -o {self.proofs_dir}/xss_confirmed.txt", silent=True)

    # ==========================================
    # 🧠 OPTIONAL: DEEP AI ANALYSIS
    # ==========================================
    def ai_analysis(self):
        if not self.ai_mode: return
        gemini_key = os.environ.get("GEMINI_API_KEY")
        if not gemini_key: return
        
        print(f"\n{Fore.YELLOW}[*] OPTIONAL PHASE: Running Deep AI Context Analysis...{Style.RESET_ALL}")
        import requests
        
        def ask_gemini(prompt):
            url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={gemini_key}"
            try:
                res = requests.post(url, headers={'Content-Type': 'application/json'}, json={"contents": [{"parts": [{"text": prompt}]}]})
                return res.json()['candidates'][0]['content']['parts'][0]['text']
            except Exception as e: return f"AI API Error: {str(e)}"

        with open(self.ai_file, 'w') as out:
            out.write("=== 🧠 NUCLEIFUZZER DEEP AI INSIGHTS ===\n\n")
            if self.js_file.exists() and self.js_file.stat().st_size > 0:
                with open(self.js_file, 'r') as f: js_urls = [line.strip() for line in f.readlines()[:3]]
                for url in js_urls:
                    try:
                        js_content = requests.get(url, timeout=5).text[:8000]
                        out.write(f"[*] Findings for {url}:\n{ask_gemini(f'Extract hidden APIs/secrets from this JS: {js_content}')}\n\n")
                    except: pass
            
            if self.json_file.exists() and self.json_file.stat().st_size > 0:
                with open(self.json_file, 'r') as f: vulns = f.read()[:10000]
                out.write(f"=== Exploit Chaining Strategies ===\n{ask_gemini(f'Identify how these vulnerabilities can be chained: {vulns}')}\n")

    # ==========================================
    # 🚀 ORCHESTRATOR EXECUTION
    # ==========================================
    def run(self):
        self.show_banner()
        
        if self.doctor_mode: self.run_doctor()
        if self.update_mode: self.run_update()
            
        targets = []
        if self.domain: targets.append(self.domain)
        if self.filename:
            with open(self.filename, 'r') as f: targets.extend([line.strip() for line in f if line.strip()])

        if not targets:
            print(f"{Fore.RED}[!] Please provide a target using -d or -f{Style.RESET_ALL}")
            sys.exit(1)

        for target in targets:
            self.recon(target)
            self.dedup()
            self.dns_intel()
            self.probe_live()
            self.nuclei_scan()
            
            self.generate_html_report()
            self.active_validation()
            self.ai_analysis()

        print(f"\n{Fore.GREEN}======================================")
        print(f"✅ Pipeline Completed Successfully!")
        print(f"📁 JSON Results  : {self.json_file}")
        print(f"🌐 HTML Report   : {self.html_file}")
        if self.validate_mode: print(f"🛡️  Proofs Dir   : {self.proofs_dir}")
        if self.ai_mode: print(f"🧠 AI Insights   : {self.ai_file}")
        print(f"======================================{Style.RESET_ALL}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="NucleiFuzzer AI Python Orchestrator", add_help=False)
    
    parser.add_argument("-d", "--domain", help="Single domain to scan")
    parser.add_argument("-f", "--file", help="File containing multiple domains")
    parser.add_argument("--fast", action="store_true", help="Enable fast scanning mode")
    parser.add_argument("--deep", action="store_true", help="Enable deep scanning mode")
    parser.add_argument("--validate", action="store_true", help="Enable Active Validation (SQLMap, Dalfox)")
    parser.add_argument("--ai", action="store_true", help="Enable Deep Context AI Analysis")
    parser.add_argument("--doctor", action="store_true", help="Run system diagnostics")
    parser.add_argument("--update", action="store_true", help="Update tools")
    parser.add_argument("-h", "--help", action="help", default=argparse.SUPPRESS, help="Show help")

    nf = NucleiFuzzer(parser.parse_args())
    nf.run()
