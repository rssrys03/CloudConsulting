public with sharing class HoursAssignment {
    public static Integer calculateHours(Date startDate, Date endDate) {
        Integer totalDays = (startDate-1).daysBetween(endDate);
        
        for (Date start = startDate; start <= endDate; start = start.addDays(1)) {       
            Integer day = start.day();
        	Integer month = start.month();
        	Integer year = start.year();
        	DateTime startDateTime = DateTime.newInstance(year, month, day);
        	String dayString= startDateTime.format('E');

            if(dayString == 'Sat' || dayString == 'Sun'){
                totalDays--;
            }
         }
        
        return totalDays * 8;
    }
}