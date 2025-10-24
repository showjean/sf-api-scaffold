/**
 * @description ApiRestRouterSales
 * Created by fsj on 2025-10-22
 */
public with sharing class ApiRestRouterSales extends APIRouterSuper {
    public ApiRestRouterSales() {
        super();
    }

    public override APIContext route(APIContext aContext, String aPrevPath, String aPath) {
        String kApiId = aContext.pathVar.get('apiId');

        // 경로에 포함된 api id 를 기준으로 프로세서 구분
        APIProcessor kApiProcessor;
        if ('a' == kApiId) {
            kApiProcessor = new SimpleProcessor(kApiId);
        } else if ('b' == kApiId) {
            kApiProcessor = new SimpleProcessor(kApiId);
        }
        
        return new APIContext.Builder(aContext)
                .processor(kApiProcessor)
                .build();
    }
}