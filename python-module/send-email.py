import pandas as pd
# df = pd.DataFrame({'foo': ['one', 'one', 'one', 'two', 'two',
#                            'two'],
#                    'bar': ['A', 'B', 'C', 'A', 'B', 'C'],
#                    'baz': [1, 2, 3, 4, 5, 6],
#                    'zoo': ['x', 'y', 'z', 'q', 'w', 't']})

data_value = pd.read_excel('D:\\py-project\\Nandha.xlsx')
#pd.show_versions()
#data_value['Row ID'] = range(len(data_value))
#print(data_value)

pivot_table = pd.pivot_table(data_value, 
                              index=['Plugin Name', 'Port', 'IP Address'],
                              columns= 'Severity',
                              #values='Plugin Name',
                              aggfunc=('size'),
                              #margins = True,
                              #margins_name='grand_total',
                              fill_value=0)

#pivot_table.to_excel('sample.xlsx', sheet_name='pivot')
pivot_table=pd.pivot_table(data_value, index=['Severity'], aggfunc=['size'], fill_value=0)
print(pivot_table)