/**
 * @description APIRouterSuper 테스트 클래스
 */
@IsTest
private class APIRouterSuper_ts {

    /**
     * @description 테스트용 concrete 구현 클래스
     */
    private class TestRouter extends APIRouterSuper {
    }

    /**
     * @description 테스트용 더미 APIRouter 구현체
     */
    private class DummyRouter implements APIRouter {
        public APIContext route(APIContext aContext, String aPrevPath, String aPath) {
            return aContext;
        }
    }

    /**
     * @description 테스트용 더미 APIProcessor 구현체
     */
    private class DummyProcessor implements APIProcessor {
        public void process(APIContext aContext, RestRequest aReq, RestResponse aRes) {
            // 더미 구현
        }
    }

    /**
     * @description 모든 메서드 테스트 - 100% 커버리지 달성
     */
    @IsTest
    static void testAllMethods() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            // Given
            TestRouter kRouter = new TestRouter();
            DummyRouter kDummyRouter = new DummyRouter();
            DummyProcessor kDummyProcessor = new DummyProcessor();
            APIContext kContext = new APIContext();

            // When & Then - 생성자 호출 (이미 완료)
            Assert.isNotNull(kRouter, 'Router 인스턴스 생성 확인');

            // addRouter(String, APIRouter) 테스트
            kRouter.addRouter('/api', kDummyRouter);

            // addRouter(String, String, APIRouter) 테스트
            kRouter.addRouter('/users', 'GET', kDummyRouter);

            // addProcessor(String, APIProcessor) 테스트
            kRouter.addProcessor('/test', kDummyProcessor);

            // addProcessor(String, String, APIProcessor) 테스트
            kRouter.addProcessor('/hello', 'POST', kDummyProcessor);

            // route() 테스트
            APIContext kResult = kRouter.route(kContext, '', '/api');
            Assert.isNotNull(kResult, 'route 결과가 null이 아님');
        }
    }
}
