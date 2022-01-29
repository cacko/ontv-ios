import csv
from io import StringIO
from pathlib import Path
from dataclasses import asdict, dataclass, asdict

DEFAULT = [
      8,
      25,
      17,
      11,
      13,
      7,
      6265,
      163,
      350,
      5668,
      573,
      5421,
      7016,
      7685,
      572,
      15,
      167,
      9,
      20,
      1
]

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
		League(name=name, id=int(id), default="true" if int(id) in DEFAULT else "false") 
		for (id,name) in csv_reader
		], key=lambda x: x.name)
	for league in leagues:
		print(TEMPLATE.format(**asdict(league)))
	
