 
    import java.math.BigInteger;   
      
    public class Kettle {  
        private static  int RADIX = 16;   
        private static  String SEED = "0933910847463829827159347601486730416058";   
          
        public static final String encryptPassword(String password)    
        {    
            if (password==null) return "";    
            if (password.length()==0) return "";    
                
            BigInteger bi_passwd = new BigInteger(password.getBytes());    
                
            BigInteger bi_r0  = new BigInteger(SEED);    
            BigInteger bi_r1  = bi_r0.xor(bi_passwd);    
                
            return bi_r1.toString(RADIX);     
        }    
          
          
        public static  String decryptPassword(String encrypted)   
        {   
                 if (encrypted==null) return "";   
                 if (encrypted.length()==0) return "";   
                    
                 BigInteger bi_confuse  = new BigInteger(SEED);   
                    
                 try   
                 {   
                         BigInteger bi_r1 = new BigInteger(encrypted, RADIX);   
                         BigInteger bi_r0 = bi_r1.xor(bi_confuse);   
                            
                         return new String(bi_r0.toByteArray());    
                 }   
                 catch(Exception e)   
                 {   
                         return "";   
                 }   
         }   
      
        public static void main(String[] args) {  
            System.out.println(Kettle.decryptPassword("2be98afc86aa7b48ba80cbd4ff393a6d6"));  
        }  
    }  