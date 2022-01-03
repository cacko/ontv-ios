import csv
from pathlib import Path

DEFAULTS = [43, 41, 44, 45, 39, 256, 84, 247, 558, 246, 147, 195, 2442, 625, 31, 908]

TEMPLATE = """<dict>
			<key>Type</key>
			<string>PSToggleSwitchSpecifier</string>
			<key>Title</key>
			<string>{name}</string>
			<key>Key</key>
			<string>livescores_league_{id}</string>
			<key>DefaultValue</key>
			<{default}/>
		</dict>"""

csv_path = Path(__file__).parent / "leagues.csv"

with csv_path.open("r") as f:
    csv_reader = csv.reader(f)
    for (id,name) in csv_reader:
        print(TEMPLATE.format(name=name, id=id, default="true" if int(id) in DEFAULTS else "false"))