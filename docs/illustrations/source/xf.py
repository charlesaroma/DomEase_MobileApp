import re, math
def rot(d, ang, cx=48, cy=48, sx=1.0, sy=1.0, dx=0, dy=0):
    """Rotate (degrees) an absolute path about (cx,cy), then scale and move. H/V become L."""
    a=math.radians(ang); ca,sa=math.cos(a),math.sin(a)
    def P(x,y):
        x-=cx; y-=cy
        return (cx+(x*ca-y*sa)*sx+dx, cy+(x*sa+y*ca)*sy+dy)
    toks=re.findall(r'[MLHVCQAZ]|-?\d*\.?\d+',d)
    out=[]; i=0; cur=(0,0); cmd=None
    def num():
        nonlocal i; v=float(toks[i]); i+=1; return v
    while i<len(toks):
        t=toks[i]
        if re.match('[A-Z]',t): cmd=t; i+=1
        if cmd=='Z': out.append('Z'); continue
        if cmd in 'ML':
            x,y=num(),num(); cur=(x,y); p=P(x,y); out.append(f'{cmd}{p[0]:.2f} {p[1]:.2f}')
        elif cmd=='H':
            x=num(); cur=(x,cur[1]); p=P(*cur); out.append(f'L{p[0]:.2f} {p[1]:.2f}')
        elif cmd=='V':
            y=num(); cur=(cur[0],y); p=P(*cur); out.append(f'L{p[0]:.2f} {p[1]:.2f}')
        elif cmd=='C':
            ps=[(num(),num()) for _ in range(3)]; cur=ps[-1]
            out.append('C'+' '.join(f'{P(*q)[0]:.2f} {P(*q)[1]:.2f}' for q in ps))
        elif cmd=='Q':
            ps=[(num(),num()) for _ in range(2)]; cur=ps[-1]
            out.append('Q'+' '.join(f'{P(*q)[0]:.2f} {P(*q)[1]:.2f}' for q in ps))
        elif cmd=='A':
            rx,ry,xr,la,sw,x,y=[num() for _ in range(7)]; cur=(x,y); p=P(x,y)
            out.append(f'A{rx*sx:.2f} {ry*sy:.2f} {xr+ang:.2f} {int(la)} {int(sw)} {p[0]:.2f} {p[1]:.2f}')
    return ' '.join(out)
