#!/usr/bin/env python3

# ==============================================================================
# 📦 SECTION 1: SYSTEM IMPORTS
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

init(autoreset=True)

# ==============================================================================
# 🚀 SECTION 2: THE CORE ENGINE CLASS
# ==============================================================================
class NucleiFuzzer:
    def __init__(self, args):
        # ----------------------------------------------------------------------
        # 🛠️ SYSTEM PATH FIX (Crucial for Go tools like Dalfox & Subpipe)
        # ----------------------------------------------------------------------
        go_bin = os.path.expanduser("~/go/bin")
        local_bin = os.path.expanduser("~/.local/bin")
        
        if go_bin not in os.environ.get("PATH", ""):
            os.environ["PATH"] += os.pathsep + go_bin
            
        if local_bin not in os.environ.get("PATH", ""):
            os.environ["PATH"] += os.pathsep + local_bin

        self.domain = args.domain
        self.filename = args.file
        self.ai_mode = args.ai
        self.validate_mode = args.validate
        self.fast_mode = args.fast
        self.deep_mode = args.deep
        self.doctor_mode = args.doctor
        self.update_mode = args.update
        
        self.base_dir = Path.cwd()
        self.base_output_dir = self.base_dir / "output"
        
        self.rate_limit = 200 if self.fast_mode else 50
        self.excluded_exts = "png,jpg,gif,jpeg,swf,woff,svg,pdf,json,css,js,webp,woff,woff2,eot,ttf,otf,mp4,txt"

    # --------------------------------------------------------------------------
    # 📁 FUNCTION: set_target_workspace
    # --------------------------------------------------------------------------
    def set_target_workspace(self, target):
        safe_target = target.replace("http://", "").replace("https://", "").split("/")[0]
        
        self.output_dir = self.base_output_dir / safe_target
        self.proofs_dir = self.output_dir / "proofs"
        
        if not self.doctor_mode and not self.update_mode:
            self.output_dir.mkdir(parents=True, exist_ok=True)
            self.proofs_dir.mkdir(parents=True, exist_ok=True)
            
        self.raw_file = self.output_dir / "raw.txt"
        self.validated_file = self.output_dir / "validated.txt"
        self.live_file = self.output_dir / "live.txt"
        self.json_file = self.output_dir / "results.json"
        self.html_file = self.output_dir / "report.html"
        self.js_file = self.output_dir / "js_endpoints.txt"
        self.ai_file = self.output_dir / "ai_insights.txt"
        self.dns_file = self.output_dir / "dns_intel.txt"

    # --------------------------------------------------------------------------
    # 🎨 FUNCTION: show_banner
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
                                               High-Speed Pipeline + Target Isolation
{Style.RESET_ALL}"""
        print(banner)

    # --------------------------------------------------------------------------
    # 💻 FUNCTION: run_command
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
            "subpipe": "github.com/subpipe/subpipe@latest"
        }

        installed_any = False
        print(f"{Fore.BLUE}[*] Checking and installing missing tools...{Style.RESET_ALL}")
        
        for tool, path in go_tools.items():
            if not shutil.which(tool):
                print(f"{Fore.YELLOW}[!] {tool} is missing. Installing...{Style.RESET_ALL}")
                self.run_command(f"go install -v {path}", silent=False) 
                installed_any = True
            else:
                print(f"{Fore.GREEN}[OK] {tool} is already installed.{Style.RESET_ALL}")

        if not shutil.which("sqlmap"):
            print(f"{Fore.YELLOW}[!] sqlmap is missing. Installing via apt...{Style.RESET_ALL}")
            self.run_command("sudo apt-get update && sudo apt-get install sqlmap -y", silent=False)
            installed_any = True

        param_path = os.path.expanduser("~/ParamSpider")
        if not os.path.exists(param_path):
            print(f"{Fore.YELLOW}[!] ParamSpider is missing. Cloning repository...{Style.RESET_ALL}")
            self.run_command(f"git clone https://github.com/0xKayala/ParamSpider {param_path}", silent=False)
            installed_any = True

        self.run_command("nuclei -update-templates", silent=True)
        print(f"\n{Fore.GREEN}✅ Smart update complete. System is ready.{Style.RESET_ALL}")
        sys.exit(0)

    # --------------------------------------------------------------------------
    # 🔍 FUNCTION: recon (PHASE 1)
    # --------------------------------------------------------------------------
    def recon(self, target):
        print(f"\n{Fore.BLUE}[*] PHASE 1: Starting Parallel Recon & URL Collection for {target}...{Style.RESET_ALL}")
        
        target_url = target if target.startswith("http") else f"http://{target}"
        target_domain = target.replace("http://", "").replace("https://", "").split("/")[0]

        commands = {
            "ParamSpider": f"python3 ~/ParamSpider/paramspider.py -d {target_domain} --exclude {self.excluded_exts} --level high --quiet -o {self.output_dir}/param.txt",
            "Waybackurls": f"echo {target_domain} | waybackurls > {self.output_dir}/wayback.txt",
            "Gauplus": f"echo {target_domain} | gauplus -subs -b {self.excluded_exts} > {self.output_dir}/gau.txt",
            "Hakrawler": f"echo {target_url} | hakrawler -d 3 -subs -u > {self.output_dir}/hakrawler.txt",
            "Katana": f"echo {target_url} | katana -d 3 -silent > {self.output_dir}/katana.txt"
        }

        with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
            futures = {executor.submit(self.run_command, cmd, True): name for name, cmd in commands.items()}
            for future in concurrent.futures.as_completed(futures):
                print(f"{Fore.GREEN}[+] {futures[future]} completed.{Style.RESET_ALL}")

        self.run_command(f"cat {self.output_dir}/*.txt | grep -aE '^https?://' > {self.raw_file}", silent=True)
        self.run_command(rf"grep -aEi '\.js(\?|$)' {self.raw_file} > {self.js_file}", silent=True)

    # --------------------------------------------------------------------------
    # 🧹 FUNCTION: dedup (PHASE 2)
    # --------------------------------------------------------------------------
    def dedup(self):
        print(f"\n{Fore.BLUE}[*] PHASE 2: Deduplicating URLs...{Style.RESET_ALL}")
        if not self.raw_file.exists() or self.raw_file.stat().st_size == 0:
            print(f"{Fore.RED}[!] No URLs found during recon. Exiting.{Style.RESET_ALL}")
            return False
        self.run_command(f"sort -u {self.raw_file} | uro > {self.validated_file}")
        return True

    # --------------------------------------------------------------------------
    # 🌐 FUNCTION: dns_intel (PHASE 3)
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
    # --------------------------------------------------------------------------
    def probe_live(self):
        print(f"\n{Fore.BLUE}[*] PHASE 4: Probing live hosts with httpx (WAF Evasion Enabled)...{Style.RESET_ALL}")
        
        cmd = f"httpx -silent -mc 200,204,301,302,401,403,405,500,502,503,504 -random-agent -timeout 10 -retries 2 -rl {self.rate_limit} -l {self.validated_file} -o {self.live_file}"
        self.run_command(cmd, silent=True)
        
        if not self.live_file.exists() or self.live_file.stat().st_size == 0:
            print(f"{Fore.YELLOW}[WARN] httpx found 0 live hosts. The target may be down or aggressively blocking requests (WAF).{Style.RESET_ALL}")
            print(f"{Fore.RED}[!] Aborting Nuclei scan for this target to protect your IP from being banned.{Style.RESET_ALL}")
            return False
            
        return True

    # --------------------------------------------------------------------------
    # ⚡ FUNCTION: nuclei_scan (PHASE 5)
    # --------------------------------------------------------------------------
    def nuclei_scan(self):
        print(f"\n{Fore.BLUE}[*] PHASE 5: Running Nuclei DAST Scan (Rate: {self.rate_limit})...{Style.RESET_ALL}")
        templates = os.path.expanduser("~/nuclei-templates")
        
        # FIXED: Removed the invalid '-color' flag. Nuclei outputs colors by default automatically.
        cmd = f"nuclei -l {self.live_file} -t {templates} -dast -rl {self.rate_limit} -je {self.json_file}"
        
        try:
            process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
            
            for line in process.stdout:
                if "Skipped" in line and "unresponsive" in line:
                    continue
                print(line, end="")
                
            process.wait()
            
        except Exception as e:
            print(f"{Fore.RED}[WARN] Nuclei encountered an execution error: {str(e)}{Style.RESET_ALL}")

    # --------------------------------------------------------------------------
    # 📊 FUNCTION: generate_html_report
    # --------------------------------------------------------------------------
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
                        d = json.loads(line)
                        if isinstance(d, dict):
                            findings.append(d)
                            s = d.get('info', {}).get('severity', 'info').lower()
                            if s in counts: counts[s] += 1
                            elif s == 'unknown': counts['info'] += 1 
                    except: pass
        
        sev_order = {"critical": 0, "high": 1, "medium": 2, "low": 3, "info": 4, "unknown": 5}
        findings.sort(key=lambda x: sev_order.get(x.get('info', {}).get('severity', 'info').lower(), 6))

        html_tpl = f"""<!DOCTYPE html><html><head><title>NucleiFuzzer Results</title>
        <style>
            body {{ background: #121212; color: #e0e0e0; font-family: 'Segoe UI', sans-serif; padding: 40px; }}
            .summary {{ display: flex; gap: 20px; margin-bottom: 30px; }}
            .box {{ background: #1e1e1e; padding: 15px 30px; border-radius: 8px; text-align: center; min-width: 100px; border-left: 5px solid #333; }}
            .critical {{ border-color: #ff4444; color: #ff4444; }} 
            .high {{ border-color: #ff8800; color: #ff8800; }}
            .medium {{ border-color: #ffcc00; color: #ffcc00; }}
            .low {{ border-color: #00ccff; color: #00ccff; }}
            .info {{ border-color: #aaaaaa; color: #aaaaaa; }}
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
            <div class="box info"><h3>Info</h3><h2>{counts['info']}</h2></div>
        </div>
        <table><tr><th>Severity</th><th>Vulnerability</th><th>Target URL</th></tr>"""
        
        for f in findings:
            s = f.get('info', {}).get('severity', 'info').lower()
            n = html.escape(f.get('info', {}).get('name', 'Unknown'))
            u = html.escape(f.get('matched-at', ''))
            html_tpl += f"<tr><td class='{s}'><b>{s.upper()}</b></td><td>{n}</td><td><a href='{u}' target='_blank'>{u}</a></td></tr>"
        
        with open(self.html_file, 'w') as f: 
            f.write(html_tpl + "</table></body></html>")

    # --------------------------------------------------------------------------
    # 🎯 FUNCTION: active_validation
    # --------------------------------------------------------------------------
    def active_validation(self):
        if not self.validate_mode or not self.json_file.exists() or self.json_file.stat().st_size == 0:
            return
        print(f"\n{Fore.YELLOW}[*] OPTIONAL PHASE: Initializing Active Validation (sqlmap/dalfox)...{Style.RESET_ALL}")
        with open(self.json_file, 'r') as f:
            v = [json.loads(l) for l in f if l.strip()]

        sqli = [x['matched-at'] for x in v if 'sqli' in x.get('info', {}).get('name', '').lower()]
        if sqli and shutil.which("sqlmap"):
            for t in set(sqli): 
                self.run_command(f"sqlmap -u \"{t}\" --batch --level 1 --risk 1 --dbs --output-dir={self.proofs_dir}/sqlmap", silent=True)

        xss = [x['matched-at'] for x in v if 'xss' in x.get('info', {}).get('name', '').lower()]
        if xss and shutil.which("dalfox"):
            xf = self.output_dir / "xss_targets.txt"
            with open(xf, 'w') as f: f.write("\n".join(set(xss)))
            self.run_command(f"dalfox file {xf} -o {self.proofs_dir}/xss_confirmed.txt", silent=True)

    # --------------------------------------------------------------------------
    # 🧠 FUNCTION: ai_analysis
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
                if 'error' in data: return f"API Error: {data['error'].get('message', 'Unknown error')}"
                if 'candidates' not in data or not data['candidates']: return "AI Blocked Request: No candidates returned (Safety Filters)."
                return data['candidates'][0]['content']['parts'][0]['text']
            except Exception as e: return f"AI System Error: {str(e)}"

        with open(self.ai_file, 'w') as out:
            out.write("=== 🧠 NUCLEIFUZZER DEEP AI INSIGHTS ===\n")
            out.write(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

            if self.js_file.exists() and self.js_file.stat().st_size > 0:
                print(f"{Fore.CYAN}[*] Extracting logic from key JavaScript files...{Style.RESET_ALL}")
                with open(self.js_file, 'r') as f:
                    js_urls = [line.strip() for line in f.readlines()[:3]] 
                
                for url in js_urls:
                    try:
                        js_content = requests.get(url, timeout=5).text[:8000]
                        prompt = f"Act as an elite bug hunter. Extract hidden API endpoints and secrets as a bulleted list from this JS: {js_content}"
                        out.write(f"[*] Findings for {url}:\n{ask_gemini(prompt)}\n\n")
                    except Exception as e:
                        out.write(f"[*] Failed to fetch {url}: {str(e)}\n\n")

            if self.json_file.exists() and self.json_file.stat().st_size > 0:
                print(f"{Fore.CYAN}[*] Strategizing attack chains from Nuclei results...{Style.RESET_ALL}")
                with open(self.json_file, 'r') as f:
                    vulns = f.read()[:10000]
                prompt = f"Review this vulnerability report. Identify potential exploit chains (e.g., LFI to RCE). Provide strategy: {vulns}"
                out.write(f"=== Exploit Chaining Strategies ===\n{ask_gemini(prompt)}\n")

        print(f"{Fore.GREEN}[+] AI Insights successfully saved to {self.ai_file}{Style.RESET_ALL}")

    # --------------------------------------------------------------------------
    # 🚀 FUNCTION: run
    # --------------------------------------------------------------------------
    def run(self):
        self.show_banner()
        if self.doctor_mode: self.run_doctor()
        if self.update_mode: self.run_update()
        
        targets = [self.domain] if self.domain else []
        if self.filename:
            with open(self.filename, 'r') as f: targets.extend([l.strip() for l in f if l.strip()])
        if not targets: sys.exit(f"{Fore.RED}[!] No target provided. Use -h for help.{Style.RESET_ALL}")

        for t in targets:
            self.set_target_workspace(t)
            self.recon(t)
            
            if not self.dedup():
                continue 
                
            self.dns_intel()
            
            if not self.probe_live():
                continue
                
            self.nuclei_scan()
            self.generate_html_report()
            self.active_validation()
            self.ai_analysis()
            
            print(f"\n{Fore.GREEN}======================================")
            print(f"✅ Pipeline Completed Successfully for: {t}")
            print(f"📁 Workspace Area : {self.output_dir}/")
            print(f"📄 JSON Results   : {self.json_file.name}")
            print(f"🌐 HTML Report    : {self.html_file.name}")
            if self.validate_mode: print(f"🛡️  Proofs Dir     : proofs/")
            if self.ai_mode:       print(f"🧠 AI Insights    : {self.ai_file.name}")
            print(f"======================================{Style.RESET_ALL}")

# ==============================================================================
# 🛠️ SECTION 3: ARGUMENT PARSING & HELP MENU
# ==============================================================================
if __name__ == "__main__":
    custom_epilog = f"""
{Fore.CYAN}Examples & Usage Insights:{Style.RESET_ALL}
  {Fore.GREEN}1. Standard Scan:{Style.RESET_ALL}      nf -d example.com
  {Fore.GREEN}2. Fast Batch Scan:{Style.RESET_ALL}    nf -f targets.txt --fast
  {Fore.GREEN}3. Next-Gen Attack:{Style.RESET_ALL}    nf -d example.com --validate --ai
                         {Fore.YELLOW}└─> '--validate' automatically runs SQLMap/Dalfox on SQLi/XSS findings.{Style.RESET_ALL}
                         {Fore.YELLOW}└─> '--ai' sends logic/endpoints to Gemini to suggest exploit chains.{Style.RESET_ALL}
  {Fore.GREEN}4. System Diagnostics:{Style.RESET_ALL} nf --doctor
  {Fore.GREEN}5. Smart Install:{Style.RESET_ALL}      nf --update
"""
    parser = argparse.ArgumentParser(
        description=f"{Fore.RED}NucleiFuzzer v4.0 - Master Python Engine{Style.RESET_ALL}",
        epilog=custom_epilog,
        formatter_class=argparse.RawTextHelpFormatter,
        add_help=False
    )
    
    parser.add_argument("-d", "--domain", help="Single domain to scan (e.g., target.com)")
    parser.add_argument("-f", "--file", help="File containing multiple domains (e.g., list.txt)")
    parser.add_argument("--fast", action="store_true", help="Enable fast scanning mode (Higher Rate Limit: 200)")
    parser.add_argument("--deep", action="store_true", help="Enable deep scanning mode (Lower Rate Limit: 50)")
    parser.add_argument("--validate", action="store_true", help="Enable Active Validation (Proves vulns with SQLMap/Dalfox)")
    parser.add_argument("--ai", action="store_true", help="Enable Deep Context AI Analysis (Requires GEMINI_API_KEY)")
    parser.add_argument("--doctor", action="store_true", help="Run system diagnostics (Checks tools & API keys)")
    parser.add_argument("--update", action="store_true", help="Smart Update (Installs missing tools & updates templates)")
    parser.add_argument("-h", "--help", action="help", default=argparse.SUPPRESS, help="Show this extended help message and exit")
    
    nf = NucleiFuzzer(parser.parse_args())
    nf.run()
