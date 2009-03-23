from __future__ import with_statement
import sqlite3
import random

conn = sqlite3.connect("fake_data.db")
c = conn.cursor()

# Create table
c.execute("""create table genomes(pop_index int, generation int, fitness real, encoding text)""")


ENCODE_LENGTH = 25 #i made up this length, need to know actual length
for gen in range(0,4):
    for i in range(0,101):
        fit = random.uniform(0,1+gen)
        encode = "".join([str(random.randint(0,1)) for x in range(ENCODE_LENGTH+1)])
        c.execute("insert into genomes values (?,?,?,?)",(i,gen,fit,encode))
        
conn.commit()

"""
#test to make sure the data went in
data = conn.execute('select * from genomes order by generation,pop_index')

for row in data: 
    print row
"""