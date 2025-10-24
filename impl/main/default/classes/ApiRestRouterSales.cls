/**
 * @description ApiRestRouterSales
 * Created by fsj on 2025-10-22
 */
public with sharing class ApiRestRouterSales extends APIRouterSuper {
    public ApiRestRouterSales() {
        super();
    }

    public override APIContext route(APIContext aContext, String aPrevPath, String aPath) {
        String kModule = aContext.pathVar.get('mod') ?? '';
        String kApiId = aContext.pathVar.get('apiId') ?? '';
        String kLabel = kModule + ':' + kApiId;

                // 경로에 포함된 api id 를 기준으로 프로세서 구분
        APIProcessor kApiProcessor;
        if (kApiId.startsWith('a')) {
            kApiProcessor = new SimpleProcessor(kLabel);
        } else if (kApiId.startsWith('b')) {
            kApiProcessor = new SimpleProcessor(kLabel);
        }
        
        return new APIContext.Builder(aContext)
                .processor(kApiProcessor ?? new APINotFoundProcessor())
                .build();
    }
}