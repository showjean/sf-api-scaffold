/**
 * @description ApiRestRouterSales
 * Created by fsj on 2025-10-22
 */
public with sharing class ApiRestRouterSales extends APIRouterSuper {
    public ApiRestRouterSales() {
        super();
    }

    public override APIContext route(APIContext aContext, String aPrevPath, String aPath) {
        return new APIContext.Builder(aContext)
                .processor(new HealthCheckProcessor(aContext.pathVar.get('apiId')))
                .build();
    }
}