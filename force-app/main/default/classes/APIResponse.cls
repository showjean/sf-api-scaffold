/**
 * @description APIResponse
 * Created by fsj on 2025-10-24
 */
public class APIResponse {
    public Boolean success;
    public String requestUrl;
    public String timestamp;
    public APIError error;
    
    public class APIError {
        public String type;
        public String message;
    }
}