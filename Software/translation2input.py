sequence_file = input("sequence file:")
output = open('in.pattern', 'w')
source = open(sequence_file, 'r')
seq = [[],[]]
dic = {'A': '00', 'T': '01', 'C': '10', 'G': '11' }
dic2 = {0 : '10', 1: '01'}
iter = 0
for line in source:
    for i in range(len(line)):
        if(line[i] != '\n'):
            seq[iter].append(dic[line[i]])
    iter = iter + 1

output.write('00 00\n')
for i in range(len(seq)):
    for j in range(len(seq[i])):
        output.write(dic2[i])
        output.write(' ')
        output.write(seq[i][j])
        output.write('\n')
    
output.write('11 00\n')