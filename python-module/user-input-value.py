## Find the price after the discount
# def my_discount():
#     price_value= eval(input("Enter the price amount in number:"))
#     discount_value= eval(input("Enter the discount amount:"))
#     discount_price_amount = price_value - ((price_value/100)*discount_value)
#     print (discount_price_amount)
#     #return discount_price_amount

# my_discount()

## count the male and female value and print in tuples
# def student_sex(student_value):
#      countter = []
#      counter_2 = []
#      mle = 0
#      femal = 0
#      for i in student_value:
#           if i == 'male':
#                countter.append(i)
#           else:
#                counter_2.append(i)
#      for j in countter:
#         mle += 1
#      for l in counter_2:
#         femal += 1
#      m = ('Male',mle)
#      f = ('Female',femal)
#      print([m,f])   

# students = ['male','female','male','male','male','male','male', 'male',
#             'male','female','female','female','female','female','female']

# student_sex(students)


##find the biggest odd number from the input
# def find_biggest_odd(odd_Value):
#     count= []
#     for i in odd_Value:
#         if (int(i) % 2) != 0:
#             count.append(i)
#     print(max(count))

# num = eval(input ("Enter any number to find the biggest odd number in that list: "))
# find_biggest_odd(num)

## From the input print the zero value in last list if zero not availble sort the number in proper order
# def list_zero_element(element,num):
#     zro=[]
#     lst=[]
#     if '0' in num:
#         for x in num:
#             if x != element:
#               lst.append(x)
#             else:
#               zro.append(x)
#         print(lst + zro)
#     else:
#        num.sort()
#        print(num)
       
# zero_value = '0'
# num = eval(input ("Enter any number to find the biggest odd number in that list: "))
# list_zero_element(zero_value, num)


## Count the dots in string value
# def count_dots(str_value):
#     separte_dots = str_value.split('.')
#     count_of_dots = len(separte_dots) - 1
#     print (f"{count_of_dots} dots in the string")

# Dot_string = eval(input ("Enter string with dots: "))
# count_dots(Dot_string)


## Your Age in Minutes
# import datetime
# def age_in_minutes(year_val):
#     cal_to_year=int(current_year) - year_val
#     convert_to_min= cal_to_year * 525600
#     print ("you are the {:,} minutes old".format(int(convert_to_min)))
    
# def input_validation():
#     try:
#       year= int(input ("Enter your born year only with 4 digit: "))
#       global current_year
#       current_year= datetime.date.today().strftime("%Y")
#       try:
#         assert len(str(year)) <= 4,"Year should be 4 digits not more that"
#         assert year <= int(current_year), "Year should not greater than {}".format(current_year)
#         age_in_minutes(year)
#       except AssertionError as msg:
#         print(msg)
#     except ValueError as error_msg:
#       print(error_msg)

# def main():
#    input_validation()

# if __name__ =='__main__':
#     main()


##flattern_list
# def falter_list():
#     list_1=[[1,2,3,4,5]]
#     return list_1[0]

# print(falter_list())

## Teacher's Salary

# def teach_sal(name,periods):
#     if periods > 100:
#         get_more_than= periods - 100
#         salary_amout= (100 * 20) + (int(get_more_than) * 25)
#     else:
#         salary_amout= periods * 20
#     print(f"TeacherName:{name}\nNumber_of_period:{periods}\nsalray:{salary_amout}$")  
        

# teacher_name = str(input ("Enter Name of the teacher: ")).strip()
# no_of_periods = int(input ("Enter number of period taken by teacher:"))
# teach_sal(teacher_name,no_of_periods)



#find the index of list using binary search

# Iterative Binary Search Function
# It returns index of x in given array arr if present,
# else returns -1
def binary_search(arr, x):
    low = 0
    high = len(arr) - 1
    mid = 0
 
    while low <= high:
        mid = (high + low) // 2
        # If x is greater, ignore left half
        if arr[mid] < x:
            low = mid + 1
        # If x is smaller, ignore right half
        elif arr[mid] > x:
            high = mid - 1
        # means x is present at mid
        else:
            return mid
    # If we reach here, then the element was not present
    return -1
 
 
# Test array
arr = [ 2, 3, 4, 10, 40,90,100,80 ]
x = 100
 
# Function call
result = binary_search(arr, x)
 
if result != -1:
    print("Element is present at index", str(result))
else:
    print("Element is not present in array")