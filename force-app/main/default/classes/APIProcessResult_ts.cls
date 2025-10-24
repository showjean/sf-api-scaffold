/**
 * @description APIProcessResult 테스트 클래스
 */
@IsTest
private class APIProcessResult_ts {

    /**
     * @description 모든 메서드 테스트 - 100% 커버리지 달성
     */
    @IsTest
    static void testAllMethods() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            Integer kStatusCode = 200;
            String kResponseBody = 'test response';

            // When - 생성자 호출
            APIProcessResult kResult = new APIProcessResult(kStatusCode, kResponseBody);

            // Then - 생성자로 설정된 값 확인
            Assert.areEqual(200, kResult.statusCode, 'statusCode가 200이어야 함');
            Assert.areEqual('test response', kResult.res, 'res가 test response이어야 함');
            Assert.isNotNull(kResult.headers, 'headers가 초기화되어야 함');
            Assert.areEqual(0, kResult.headers.size(), 'headers가 비어있어야 함');

            // When - header() 메서드 체이닝 호출
            APIProcessResult kChainedResult = kResult
                .header('Content-Type', 'application/json')
                .header('X-Custom-Header', 'custom-value');

            // Then - header 추가 확인
            Assert.areEqual(2, kResult.headers.size(), 'headers가 2개여야 함');
            Assert.areEqual('application/json', kResult.headers.get('Content-Type'), 'Content-Type 확인');
            Assert.areEqual('custom-value', kResult.headers.get('X-Custom-Header'), 'Custom header 확인');
            Assert.areEqual(kResult, kChainedResult, 'header() 메서드는 self를 반환해야 함');
        }
    }

    @IsTest
    static void testRespond() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            Integer kStatusCode = 200;
            String kResponseBody = 'test response';

            // When - 생성자 호출
            APIProcessResult kResult = new APIProcessResult(kStatusCode, kResponseBody)
                    .header('Content-Type', 'application/json');

            RestResponse kRes = new RestResponse();
            kResult.respond(kRes);

            Assert.areEqual(200, kRes.statusCode, 'statusCode가 200이어야 함');
            Assert.areEqual('"test response"', kRes.responseBody.toString(), 'responseBody `test response`이어야 함');
            Assert.areEqual('application/json', kRes.headers.get('Content-Type'), 'Content-Type 확인');
        }
    }
}
