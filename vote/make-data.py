# this creates urlencode-friendly files without EOL
import urllib
outfile = open('postb', 'w')
params = ({ 'vote': 'b' })
encoded = urllib.urlencode(params)
outfile.write(encoded)
outfile.close()
outfile = open('posta', 'w')
params = ({ 'vote': 'a' })
encoded = urllib.urlencode(params)
outfile.write(encoded)
outfile.close()

