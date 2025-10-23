/**
 * @description DefaultExceptionHandler 단위 테스트
 */
@IsTest
private class DefaultExceptionHandler_ts {

    /**
     * @description ScaffoldException 처리 테스트 - 404 반환
     */
    @IsTest
    static void testRouteNotFoundExceptionHandling() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            DefaultExceptionHandler kHandler = new DefaultExceptionHandler();
            RestResponse kRes = new RestResponse();
            APIScaffold.ScaffoldException kEx = new APIScaffold.ScaffoldException('Route not found').statusCode(404);

            // When
            kHandler.handle(kEx, new RestRequest(), kRes);

            // Then
            Assert.areEqual(404, kRes.statusCode, 'RouteNotFoundException은 404를 반환해야 함');
            Assert.isNotNull(kRes.responseBody, 'Response body가 있어야 함');

            String kResponseBody = kRes.responseBody.toString();
            Assert.isTrue(kResponseBody.contains('success'), 'success 필드가 있어야 함');
            Assert.isTrue(kResponseBody.contains('false'), 'success는 false여야 함');
            Assert.isTrue(kResponseBody.contains('error'), 'error 필드가 있어야 함');
            Assert.isTrue(kResponseBody.contains('Route not found'), '에러 메시지가 포함되어야 함');
        }
    }

    /**
     * @description 일반 예외 처리 테스트 - 500 반환
     */
    @IsTest
    static void testGenericExceptionHandling() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            DefaultExceptionHandler kHandler = new DefaultExceptionHandler();
            RestResponse kRes = new RestResponse();
            Exception kEx = new CustomException('Something went wrong');

            // When
            kHandler.handle(kEx, new RestRequest(), kRes);

            // Then
            Assert.areEqual(500, kRes.statusCode, '일반 예외는 500을 반환해야 함');
            Assert.isNotNull(kRes.responseBody, 'Response body가 있어야 함');

            String kResponseBody = kRes.responseBody.toString();
            Assert.isTrue(kResponseBody.contains('Something went wrong'), '에러 메시지가 포함되어야 함');
        }
    }

    /**
     * @description 응답 형식 검증 테스트
     */
    @IsTest
    static void testResponseFormat() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            DefaultExceptionHandler kHandler = new DefaultExceptionHandler();
            RestResponse kRes = new RestResponse();
            Exception kEx = new CustomException('Test error');

            // When
            kHandler.handle(kEx, new RestRequest(), kRes);

            // Then
            String kResponseBody = kRes.responseBody.toString();
            Map<String, Object> kResponse = (Map<String, Object>)JSON.deserializeUntyped(kResponseBody);

            Assert.areEqual(false, kResponse.get('success'), 'success는 false여야 함');
            Assert.isTrue(kResponse.containsKey('error'), 'error 객체가 있어야 함');
            Assert.isTrue(kResponse.containsKey('timestamp'), 'error.timestamp가 있어야 함');

            Map<String, Object> kError = (Map<String, Object>)kResponse.get('error');
            Assert.isTrue(kError.containsKey('type'), 'error.type이 있어야 함');
            Assert.isTrue(kError.containsKey('message'), 'error.message가 있어야 함');
        }
    }

    /**
     * @description Content-Type 헤더 검증 테스트
     */
    @IsTest
    static void testContentTypeHeader() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            DefaultExceptionHandler kHandler = new DefaultExceptionHandler();
            RestResponse kRes = new RestResponse();
            Exception kEx = new CustomException('Test error');

            // When
            kHandler.handle(kEx, new RestRequest(), kRes);

            // Then
            Map<String, String> kHeaders = kRes.headers;
            Assert.isTrue(kHeaders.containsKey('Content-Type'), 'Content-Type 헤더가 있어야 함');
            Assert.areEqual('application/json', kHeaders.get('Content-Type'), 'Content-Type은 application/json이어야 함');
        }
    }

    /**
     * @description 예외 타입 검증 테스트
     */
    @IsTest
    static void testExceptionTypeName() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            DefaultExceptionHandler kHandler = new DefaultExceptionHandler();
            RestResponse kRes = new RestResponse();
            Exception kEx = new CustomException('Test error');

            // When
            kHandler.handle(kEx, new RestRequest(), kRes);

            // Then
            String kResponseBody = kRes.responseBody.toString();
            Map<String, Object> kResponse = (Map<String, Object>)JSON.deserializeUntyped(kResponseBody);
            Map<String, Object> kError = (Map<String, Object>)kResponse.get('error');

            String kErrorType = (String)kError.get('type');
            Assert.isTrue(kErrorType.contains('CustomException'), '예외 타입이 포함되어야 함');
        }
    }

    /**
     * @description 타임스탬프 형식 검증 테스트
     */
    @IsTest
    static void testTimestampFormat() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            DefaultExceptionHandler kHandler = new DefaultExceptionHandler();
            RestResponse kRes = new RestResponse();
            Exception kEx = new CustomException('Test error');

            // When
            kHandler.handle(kEx, new RestRequest(), kRes);

            // Then
            String kResponseBody = kRes.responseBody.toString();
            Map<String, Object> kResponse = (Map<String, Object>)JSON.deserializeUntyped(kResponseBody);
            Map<String, Object> kError = (Map<String, Object>)kResponse.get('error');

            String kTimestamp = (String)kResponse.get('timestamp');
            Assert.isNotNull(kTimestamp, 'timestamp가 있어야 함');
            Assert.isTrue(kTimestamp.contains('T'), 'ISO 8601 형식이어야 함');
            Assert.isTrue(kTimestamp.contains('Z'), 'UTC 시간이어야 함');
        }
    }

    /**
     * @description 테스트용 커스텀 예외
     */
    private class CustomException extends Exception {
    }
}
