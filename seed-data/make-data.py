# this creates urlencode-friendly files without EOL
import urllib.parse

outfile = open('postb', 'w')
params = ({ 'vote': 'b' })
encoded = urllib.parse.urlencode(params)
outfile.write(encoded)
outfile.close()
outfile = open('posta', 'w')
params = ({ 'vote': 'a' })
encoded = urllib.parse.urlencode(params)
outfile.write(encoded)
outfile.close()
