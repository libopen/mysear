"""table2Excel.py






Create Excel file with data from an Oracle database query.






Created 25-JUL-2009 by Jeffrey Kemp


"""






import cx_Oracle


from xlwt import Workbook, XFStyle, Borders, Font






def write_cursor_to_excel(curs, filename, sheetTitle):


    """write_cursor_to_excel






    curs: a cursor for an open connection to an oracle database


    filename: name of the XLS file to create


    sheetTitle: name of the sheet to create


    """


    # create style for header row - bold font, thin border below


    fnt = Font()


    fnt.bold = True


    borders = Borders()


    borders.bottom = Borders.THIN


    hdrstyle = XFStyle()


    hdrstyle.font = fnt


    hdrstyle.borders = borders


    # create a date format style for any date columns, if any


    datestyle = XFStyle()


    datestyle.num_format_str = 'DD/MM/YYYY'


    # create the workbook. (compression: try to reduce the number of repeated styles)


    wb = Workbook(style_compression=2)


    # the workbook will have just one sheet


    sh = wb.add_sheet(sheetTitle)


    # write the header line, based on the cursor description


    c = 0


    colWidth = []


    for col in curs.description:


        #col[0] is the column name


        #col[1] is the column data type


        sh.write(0, c, col[0], hdrstyle)


        colWidth.append(1) # arbitrary min cell width


        if col[1] == cx_Oracle.DATETIME:


            colWidth[-1] = len(datestyle.num_format_str)


        if colWidth[-1] < len(col[0]):


            colWidth[-1] = len(col[0])


        c += 1


    # write the songs, one to each row


    r = 1


    for song in curs:


        row = sh.row(r)


        for c in range(len(song)):


            if song[c]:


                if curs.description[c][1] == cx_Oracle.DATETIME:


                    row.write(c, song[c], datestyle)


                else:


                    if colWidth[c] < len(str(song[c])):


                        colWidth[c] = len(str(song[c]))


                    row.write(c, song[c])


        r += 1


    for c in range(len(colWidth)):


        sh.col(c).width = colWidth[c] * 350


    # freeze the header row


    sh.panes_frozen = True


    sh.vert_split_pos = 0


    sh.horz_split_pos = 1


    wb.save(filename)






def test():


    orcl = cx_Oracle.connect('scott/tiger')


    curs = orcl.cursor()


    curs.execute("""


SELECT e.ename "Employee",


       e.job "Job",


       e.hiredate "Hire Date",


       e.sal "Salary",


       e.comm "Commission",


       d.dname "Department",


       (SELECT ename FROM emp WHERE emp.empno = e.mgr) "Manager"


FROM   emp e, dept d


WHERE  e.deptno = d.deptno


""")


    write_cursor_to_excel(curs, 'emp.xls', 'Employees')






if __name__ == '__main__':


    test()