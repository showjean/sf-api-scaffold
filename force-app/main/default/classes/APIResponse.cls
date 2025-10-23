/**
 * @description API 응답 정보를 담는 클래스 (Builder 패턴)
 * Created by fsj on 2025-10-24
 */
public class APIResponse {
    /**
     * @description 성공 여부
     */
    public Boolean success { get; private set; }

    /**
     * @description 요청 URL
     */
    public String requestUrl { get; private set; }

    /**
     * @description 타임스탬프
     */
    public String timestamp { get; private set; }

    /**
     * @description 에러 정보
     */
    public APIError error { get; private set; }

    /**
     * @description private 생성자 - Builder를 통해서만 인스턴스 생성 가능
     * @param aBuilder Builder 인스턴스
     */
    private APIResponse(Builder aBuilder) {
        this.success = aBuilder.success;
        this.requestUrl = aBuilder.requestUrl;
        this.timestamp = aBuilder.timestamp;
        this.error = aBuilder.error;
    }

    /**
     * @description APIResponse Builder 클래스
     */
    public class Builder {
        private Boolean success;
        private String requestUrl;
        private String timestamp;
        private APIError error;

        /**
         * @description Builder 생성자
         */
        public Builder() {
            this.timestamp = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }

        /**
         * @description success 설정
         * @param aSuccess 성공 여부
         * @return Builder 현재 Builder 인스턴스
         */
        public Builder success(Boolean aSuccess) {
            this.success = aSuccess;
            return this;
        }

        /**
         * @description requestUrl 설정
         * @param aRequestUrl 요청 URL
         * @return Builder 현재 Builder 인스턴스
         */
        public Builder requestUrl(String aRequestUrl) {
            this.requestUrl = aRequestUrl;
            return this;
        }

        /**
         * @description timestamp 설정
         * @param aTimestamp 타임스탬프
         * @return Builder 현재 Builder 인스턴스
         */
        public Builder timestamp(String aTimestamp) {
            this.timestamp = aTimestamp;
            return this;
        }

        /**
         * @description error 설정
         * @param aType 에러 타입
         * @param aMessage 에러 메시지
         * @return Builder 현재 Builder 인스턴스
         */
        public Builder error(String aType, String aMessage) {
            this.error = new APIError(aType, aMessage);
            return this;
        }

        /**
         * @description APIResponse 인스턴스 생성
         * @return APIResponse 생성된 APIResponse 인스턴스
         */
        public APIResponse build() {
            return new APIResponse(this);
        }
    }

    /**
     * @description API 에러 정보를 담는 클래스
     */
    public class APIError {
        /**
         * @description 에러 타입
         */
        public String type { get; private set; }

        /**
         * @description 에러 메시지
         */
        public String message { get; private set; }

        /**
         * @description 생성자
         * @param aType 에러 타입
         * @param aMessage 에러 메시지
         */
        public APIError(String aType, String aMessage) {
            this.type = aType;
            this.message = aMessage;
        }
    }
}