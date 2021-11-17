@isTest
private class HoursAssignmentTest {
   @isTest
     static void  HoursAssignmentTest() {
        Date day1= date.newInstance(2021,11,15);
        Date day2=date.newInstance(2021,11,22);
        System.assertEquals(48,HoursAssignment.calculateHours(day1,day2),'El test calcula perfectamente la cantidad de horas laborales entre dos fechas');
    }
}
