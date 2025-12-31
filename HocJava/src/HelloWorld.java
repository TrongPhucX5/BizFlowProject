import java.util.Scanner;

public class HelloWorld {
public static void main(String[] args){
   System.out.println("Nhap vao chieu rong hinh chu nhat: ");
    Scanner scanner = new Scanner(System.in);
    int chieuRong = scanner.nextInt();
     System.out.println("Nhap vao chieu dai hinh chu nhat");
     int chieuDai = scanner.nextInt();

     int chuVi = (chieuDai+ chieuRong) * 2;
     int dientich = (chieuDai * chieuRong);
     int canhMin = Math.min(chieuDai, chieuRong);
     System.out.println("Chu vi = " +chuVi);
     System.out.println("Dien tich = " + dientich);
     System.out.println("Canh Min = " + canhMin);
}

}
