/**
 * @description APIProcessResult
 * Created by hyodongmin on 2025. 10. 24.
 */
public class APIProcessResult {
    public Integer statusCode { get; private set; }
    public Object res { get; private set; }
    public Map<String, String> headers { get; private set; }

    /**
     * @description Constructor
     * @param aStatusCode Http status code
     * @param aRes APIRes 를 상속한 결과 객체
     */
    public APIProcessResult(Integer aStatusCode, Object aRes) {
        this.statusCode = aStatusCode;
        this.res = aRes;
        this.headers = new Map<String, String>();
    }

    /**
     * @description 헤더 추가
     * @param aKey 키
     * @param aValue 값
     * @return self
     */
    public APIProcessResult header(String aKey, String aValue) {
        this.headers.put(aKey, aValue);
        return this;
    }

    /**
     * @description RestResponse 로 결과값을 옮긴다. (Header, statusCode, body)
     * @param aRestRes RestResponse
     */
    public void respond(RestResponse aRestRes) {
        aRestRes.statusCode = this.statusCode;
        aRestRes.headers.putAll(this.headers);
        aRestRes.responseBody = Blob.valueOf(JSON.serialize(this.res));
    }
}