import csv
from io import StringIO
from pathlib import Path
from dataclasses import asdict, dataclass, asdict

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

@dataclass
class League:
	name: str
	id: int
	default: str

with csv_path.open("r") as f:
	csv_reader = csv.reader(f)
	leagues = sorted([
		League(name=name, id=int(id), default="true" if id in DEFAULTS else "false") 
		for (id,name) in csv_reader
		], key=lambda x: x.name)
	for league in leagues:
		print(TEMPLATE.format(**asdict(league)))
	