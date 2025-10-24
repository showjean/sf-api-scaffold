/**
 * @description ApiRestRouterSample
 * Created by hyodongmin on 2025. 10. 24.
 */
public with sharing class ApiRestRouterImpl extends APIRouterSuper {

    /**
     * @description 생성자 - 라우트 초기화
     */
    public ApiRestRouterImpl() {
        this.initializeRoutes();
    }

    /**
     * @description 라우트 초기화 (상대 경로 사용)
     */
    private void initializeRoutes() {
        // 하위 라우터 등록 (상대 경로)
        this.addRouter('/sub/*', new APIRouterV2());
        
        // 경로별 프로세서 등록
        this.addProcessor('/', new SimpleProcessor('root')); // 루트
        this.addProcessor('/health', new SimpleProcessor('health')); // health
        this.addProcessor('/*', new SimpleProcessor('***')); // 나머지
    }
}