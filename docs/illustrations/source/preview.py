import sys, cairosvg
sys.path.insert(0,'.')
from dishes import DISHES, svg
names=[('groundnutStew','Groundnut stew','#FFFFFF'),('matokeKatogo','Matoke katogo','#DFECE2'),('rolex','Rolex','#E7CDA9'),('tilapia','Tilapia','#EEC6B5'),('beefPilau','Beef pilau','#C0D7C5'),('mandazi','Mandazi','#FFFFFF')]
W=3*200+4*20; H=2*200+3*20
out=f'<svg xmlns="http://www.w3.org/2000/svg" width="{W*2}" height="{H*2}" viewBox="0 0 {W} {H}"><rect width="{W}" height="{H}" rx="30" fill="#F9E0D6"/>'
for i,(k,label,bg) in enumerate(names):
    x=20+(i%3)*220; y=20+(i//3)*220
    inner=svg(DISHES[k]()).replace('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96">','').replace('</svg>','')
    out+=f'<rect x="{x}" y="{y}" width="200" height="200" rx="22" fill="{bg}"/><g transform="translate({x+46},{y+22}) scale(1.13)">{inner}</g><text x="{x+100}" y="{y+170}" text-anchor="middle" font-family="Inter, sans-serif" font-size="20" fill="#2D2520">{label}</text>'
out+='</svg>'
cairosvg.svg2png(bytestring=out.encode(),write_to=sys.argv[1])
