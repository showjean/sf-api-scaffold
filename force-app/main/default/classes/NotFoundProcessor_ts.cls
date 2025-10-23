/**
 * @description NotFoundProcessor 단위 테스트
 */
@IsTest
private class NotFoundProcessor_ts {

    /**
     * @description 404 상태 코드 반환 테스트
     */
    @IsTest
    static void testReturns404StatusCode() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            NotFoundProcessor kProcessor = new NotFoundProcessor();
            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/api/v1.0/nonexistent';
            RestResponse kRes = new RestResponse();

            // When
            kProcessor.process(new APIContext.Builder().build(), kReq, kRes);

            // Then
            Assert.areEqual(404, kRes.statusCode, '404 상태 코드를 반환해야 함');
        }
    }

    /**
     * @description 응답 본문 형식 검증 테스트
     */
    @IsTest
    static void testResponseBodyFormat() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            NotFoundProcessor kProcessor = new NotFoundProcessor();
            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/api/v1.0/nonexistent';
            RestResponse kRes = new RestResponse();

            // When
            kProcessor.process(new APIContext.Builder().build(), kReq, kRes);

            // Then
            Assert.isNotNull(kRes.responseBody, 'Response body가 있어야 함');

            String kResponseBody = kRes.responseBody.toString();
            Map<String, Object> kResponse = (Map<String, Object>)JSON.deserializeUntyped(kResponseBody);
            Map<String, Object> kError = (Map<String, Object>)kResponse.get('error');

            Assert.isTrue(kResponse.containsKey('requestUrl'), 'requestUrl 필드가 있어야 함');
            Assert.isTrue(kError.containsKey('type'), 'type 필드가 있어야 함');
            Assert.isTrue(kError.containsKey('message'), 'message 필드가 있어야 함');
        }
    }

    /**
     * @description 요청 경로가 응답에 포함되는지 테스트
     */
    @IsTest
    static void testRequestURIIncludedInResponse() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            NotFoundProcessor kProcessor = new NotFoundProcessor();
            RestRequest kReq = new RestRequest();
            String kRequestURI = '/api/v1.0/users/123/details';
            kReq.requestURI = kRequestURI;
            RestResponse kRes = new RestResponse();

            // When
            kProcessor.process(new APIContext.Builder().build(), kReq, kRes);

            // Then
            String kResponseBody = kRes.responseBody.toString();
            Map<String, Object> kResponse = (Map<String, Object>)JSON.deserializeUntyped(kResponseBody);
            Map<String, Object> kError = (Map<String, Object>)kResponse.get('error');
            Assert.areEqual(kRequestURI, kResponse.get('requestUrl'), '요청 경로가 응답에 포함되어야 함');
        }
    }

    /**
     * @description Content-Type 헤더 검증 테스트
     */
    @IsTest
    static void testContentTypeHeader() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            NotFoundProcessor kProcessor = new NotFoundProcessor();
            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/api/v1.0/nonexistent';
            RestResponse kRes = new RestResponse();

            // When
            kProcessor.process(new APIContext.Builder().build(), kReq, kRes);

            // Then
            Map<String, String> kHeaders = kRes.headers;
            Assert.isTrue(kHeaders.containsKey('Content-Type'), 'Content-Type 헤더가 있어야 함');
            Assert.areEqual('application/json', kHeaders.get('Content-Type'), 'Content-Type은 application/json이어야 함');
        }
    }

    /**
     * @description 에러 메시지 내용 검증 테스트
     */
    @IsTest
    static void testErrorMessageContent() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            NotFoundProcessor kProcessor = new NotFoundProcessor();
            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/api/v1.0/nonexistent';
            RestResponse kRes = new RestResponse();

            // When
            kProcessor.process(new APIContext.Builder().build(), kReq, kRes);

            // Then
            String kResponseBody = kRes.responseBody.toString();
            Map<String, Object> kResponse = (Map<String, Object>)JSON.deserializeUntyped(kResponseBody);
            Map<String, Object> kError = (Map<String, Object>)kResponse.get('error');
            

            Assert.areEqual('Not Found', kError.get('type'), 'error는 "Not Found"여야 함');
            Assert.areEqual('The requested resource was not found', kError.get('message'), 'message가 정확해야 함');
        }
    }

    /**
     * @description 다양한 경로에 대한 404 응답 테스트
     */
    @IsTest
    static void testVariousPathsReturn404() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            NotFoundProcessor kProcessor = new NotFoundProcessor();
            List<String> kPaths = new List<String>{
                '/api/v1.0/users',
                '/api/v2.0/orders/123',
                '/api/unknown',
                '/nonexistent/path'
            };

            // When & Then
            for (String kPath : kPaths) {
                RestRequest kReq = new RestRequest();
                kReq.requestURI = kPath;
                RestResponse kRes = new RestResponse();

                kProcessor.process(new APIContext.Builder().build(), kReq, kRes);

                Assert.areEqual(404, kRes.statusCode, kPath + '는 404를 반환해야 함');

                String kResponseBody = kRes.responseBody.toString();
                Map<String, Object> kResponse = (Map<String, Object>)JSON.deserializeUntyped(kResponseBody);
                Assert.areEqual(kPath, kResponse.get('requestUrl'), '응답에 정확한 경로가 포함되어야 함');
            }
        }
    }

    /**
     * @description JSON 직렬화 유효성 테스트
     */
    @IsTest
    static void testJSONSerializationValidity() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            NotFoundProcessor kProcessor = new NotFoundProcessor();
            RestRequest kReq = new RestRequest();
            kReq.requestURI = '/api/v1.0/test';
            RestResponse kRes = new RestResponse();

            // When
            kProcessor.process(new APIContext.Builder().build(), kReq, kRes);

            // Then
            String kResponseBody = kRes.responseBody.toString();

            try {
                Map<String, Object> kResponse = (Map<String, Object>)JSON.deserializeUntyped(kResponseBody);
                Assert.isNotNull(kResponse, 'JSON 파싱이 성공해야 함');
            }
            catch (Exception kEx) {
                Assert.fail('유효한 JSON이어야 함: ' + kEx.getMessage());
            }
        }
    }
}
