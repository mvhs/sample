import java.util.*;

public class Sample{

    /** You do not need to change this method */
    public static void main(String[] args){
        String operation = args[0];
        double a = Double.parseDouble(args[1]);
        double b = Double.parseDouble(args[2]);
        double result;
        if(operation.equals("add")){
            result = add(a, b);
        }else if(operation.equals("subtract")){
            result = subtract(a, b);
        }else if(operation.equals("multiply")){
            result = multiply(a, b);
        }else if(operation.equals("divide")){
            result = divide(a, b);
        }else result = 0;
        System.out.println(result);
    }

    /** Fix these four methods so that that tests pass! */

    public static double add(double a, double b){
        return 0;
    }

    public static double subtract(double a, double b){
        return 0;
    }

    public static double multiply(double a, double b){
        return 0;
    }

    public static double divide(double a, double b){
        return 0;
    }

}