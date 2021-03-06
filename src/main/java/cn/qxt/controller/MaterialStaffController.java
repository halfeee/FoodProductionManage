package cn.qxt.controller;

import cn.qxt.pojo.Material;
import cn.qxt.pojo.MaterialInventory;
import cn.qxt.pojo.MaterialPurchaseOrder;
import cn.qxt.pojo.MaterialRecord;
import cn.qxt.service.MaterialStaffService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
@RequestMapping("/admin/staff/material/staff")
public class MaterialStaffController {
    @Autowired
    private MaterialStaffService materialStaffService;

    /**
     * 返回员工中心界面
     * @return 路径
     */
    @RequestMapping("")
    public String materialStaffView()
    {
        return "admin/staff/material/staff";
    }

    @RequestMapping("/material-list")
    public String materialList()
    {
        return "admin/staff/material/material-list";
    }

    /**
     * 返回原材料库存详细信息
     * @return 一个List，包含需求信息： material.id as material_id, name, material_inventory.quantity as quantity, expiration_time, material_record.create_time, material_inventory.id as inventory_id
     */
    @ResponseBody
    @PostMapping(value = "/materialInfoList")
    public Map<String, Object> materialInfoList(HttpServletRequest request)
    {
        String materialID = request.getParameter("materialID");
        Map<String,Object> map = new HashMap<String, Object>();
        List <Map> materialInfoList = new ArrayList<Map>();
        if (materialID.equals(""))
        {
            materialInfoList = materialStaffService.selectAllMaterialInventoryInfo();
        }
        else
        {
            materialInfoList = materialStaffService.selectMaterialInventoryInfoByMaterialId(Integer.valueOf(materialID));
        }
        map.put("materialInfoList",materialInfoList);
        return map;
    }

    /**
     * 查找原材料的详细信息
     * @param inventory_id 原材料库存id
     * @return materialInfo:原材料的详细信息
     */
    @GetMapping(value = "/materialInfo")
    public String materialInfo(String inventory_id, HttpSession session)
    {
        if (inventory_id!=null)
        {
            Map materialInfo = materialStaffService.selectMaterialInventoryInfoById(Integer.valueOf(inventory_id));
            session.setAttribute("materialInfo",materialInfo);
            return "admin/staff/material/materialInfo";
        }
        return "admin/staff/material/materialInfo";
    }

    /**
     * 销毁过期原材料
     * @param request HttpServletRequest
     * @return Map,存放消息
     */
    @ResponseBody
    @PostMapping(value = "/destruction")
    public Map<String, Object> destruction(HttpServletRequest request)
    {
        String inventoryId = request.getParameter("inventoryId").toString();
        Map<String,Object> map = new HashMap<String, Object>();
        int ret = 0;
        try {
            materialStaffService.destroy(Integer.valueOf(inventoryId));
            ret = 1;
        }
        catch (Exception ex)
        {
            ex.printStackTrace();
        }
        map.put("ret",ret);
        return map;
    }

    @RequestMapping("/add")
    public String addMaterialView()
    {
        return "admin/staff/material/addMaterial";
    }

    @RequestMapping("/in")
    public String materialInView()
    {
        return "admin/staff/material/materialIn";
    }

    @RequestMapping("/out")
    public String materialOutView()
    {
        return "admin/staff/material/materialOut";
    }

    /**
     * 添加原材料种类
     * @param request
     * @return
     */
    @ResponseBody
    @PostMapping(value = "/addMaterial")
    public Map<String, Object> andMaterial(HttpServletRequest request)
    {
        String name = request.getParameter("name").toString();
        String shelf_time = request.getParameter("shelf_time").toString();
        Material material = new Material();
        material.setName(name);
        material.setShelf_life(Integer.valueOf(shelf_time));

        Map<String,Object> map = new HashMap<String, Object>();
        int ret = materialStaffService.andMaterial(material);
        map.put("ret",ret);
        return map;
    }

    /**
     * 返回所有的材料信息
     * @return materialList:放置着所有原材料信息
     */
    @ResponseBody
    @PostMapping(value = "/allMaterialInfoList")
    public Map<String, Object> allMaterialInfoList()
    {
        Map<String,Object> map = new HashMap<String, Object>();
        List<Material> materialList = materialStaffService.selectAllMaterial();
        map.put("materialList",materialList);
        return map;
    }

    /**
     * 入库
     * @return ret:1为成功，0为失败。
     */
    @ResponseBody
    @PostMapping(value = "/addInventory")
    public Map<String, Object> addInventory(HttpServletRequest request)
    {
        String materialId = request.getParameter("materialId").toString();
        String quantity = request.getParameter("quantity").toString();
        String shelf_life = request.getParameter("shelf_life").toString();
        MaterialInventory materialInventory = new MaterialInventory();
        materialInventory.setMaterial_id(Integer.valueOf(materialId));
        materialInventory.setQuantity(Integer.valueOf(quantity));
        //计算过期时间
        Date expiration_time = new Date();
        Calendar cal = Calendar.getInstance();
        cal.setTime(expiration_time);//设置起时间
        cal.add(Calendar.DATE, Integer.parseInt(shelf_life));
        expiration_time = cal.getTime();
        materialInventory.setExpiration_time(expiration_time);

        Map<String,Object> map = new HashMap<String, Object>();
        int ret = 0;
        try {
            materialStaffService.addInventory(materialInventory);
            ret = 1;
        }
        catch (Exception ex)
        {
            ex.printStackTrace();
        }
        map.put("ret",ret);
        return map;
    }

    @GetMapping(value = "/record")
    public String recordView()
    {
        return "admin/staff/material/record";
    }

    /**
     * 返回所有的记录
     * @return
     */
    @ResponseBody
    @PostMapping(value = "/allRecordInfo")
    public Map<String, Object> allRecordInfo()
    {
        List<MaterialRecord> inRecord = materialStaffService.selectInRecord();
        List<Map<String, Object>> inRecordInfoList = new ArrayList<Map<String, Object>>();
        for (MaterialRecord materialRecord: inRecord) {
            inRecordInfoList.add(materialStaffService.selectRecordInfoById(materialRecord.getId()));
        }

        List<MaterialRecord> outRecord = materialStaffService.selectOutRecord();
        List<Map<String, Object>> outRecordInfoList = new ArrayList<Map<String, Object>>();
        for (MaterialRecord materialRecord: outRecord) {
            outRecordInfoList.add(materialStaffService.selectRecordInfoById(materialRecord.getId()));
        }

        List<MaterialRecord> destroyRecord = materialStaffService.selectDestroyRecord();
        List<Map<String, Object>> destroyRecordInfoList = new ArrayList<Map<String, Object>>();
        for (MaterialRecord materialRecord: destroyRecord) {
            destroyRecordInfoList.add(materialStaffService.selectRecordInfoById(materialRecord.getId()));
        }

        Map<String,Object> map = new HashMap<String, Object>();
        map.put("inRecordInfoList",inRecordInfoList);
        map.put("outRecordInfoList",outRecordInfoList);
        map.put("destroyRecordInfoList",destroyRecordInfoList);
        return map;
    }

    /**
     * 返回原材料库存信息
     * @param material_idList
     * @return
     */
    @ResponseBody
    @PostMapping(value = "/classify")
    public Map<String, Object> classify(String[] material_idList)
    {
        //查找库存
        Map<String,Object> map = new HashMap<String, Object>();
        Map<String,Object> quantityMap = new HashMap<String, Object>();
        for (String material_id : material_idList)
        {
            int quantity = materialStaffService.selectAllRepertoryByMaterialId(Integer.valueOf(material_id));
            quantityMap.put(material_id, quantity);
        }
        map.put("quantityMap",quantityMap);
        return map;
    }

    /**
     * 返回需求详细信息
     * @return 一个List，包含需求信息： id:产品ID，name:产品名，quantity:数量，create_time:创建时间
     */
    @ResponseBody
    @PostMapping(value = "/requirementInfoList")
    public Map<String, Object> requirementInfoList(String materialID)
    {
        Map<String,Object> map = new HashMap<String, Object>();

        List <Map> requirementInfoList = new ArrayList<Map>();
        if (materialID.equals(""))
        {
            requirementInfoList = materialStaffService.selectReadyProcessRequirementInfo();
        }
        else
        {
            requirementInfoList = materialStaffService.selectReadyProcessRequirementInfoByMaterialID(Integer.valueOf(materialID));
        }
        map.put("requirementInfoList",requirementInfoList);
        return map;
    }

    /**
     * 出库
     * @return
     */
    @ResponseBody
    @PostMapping(value = "/inventoryOut")
    public Map<String, Object> inventoryOut(String material_id, String requirement, Integer[] requirementIdList)
    {
        int ret = 0;
        try {
            //调用事务
            materialStaffService.inventoryOut(Integer.valueOf(material_id), Integer.valueOf(requirement), requirementIdList);
            ret = 1;
        }
        catch (Exception e){
            e.printStackTrace();
        }
        Map<String,Object> map = new HashMap<String, Object>();
        map.put("ret",ret);
        return map;
    }

    @GetMapping(value = "/buy")
    public String buyView()
    {
        return "admin/staff/material/buyMaterial";
    }

    @ResponseBody
    @PostMapping(value = "/buyMaterial")
    public Map<String, Object> buyMaterial(HttpServletRequest request)
    {
        String materialId = request.getParameter("materialId");
        String quantity = request.getParameter("quantity");
        String money = request.getParameter("money");

        MaterialPurchaseOrder materialPurchaseOrder = new MaterialPurchaseOrder();
        materialPurchaseOrder.setMaterial_id(Integer.valueOf(materialId));
        materialPurchaseOrder.setMoney(Double.valueOf(money));
        materialPurchaseOrder.setQuantity(Integer.valueOf(quantity));

        int ret = materialStaffService.newMaterialPurchaseOrder(materialPurchaseOrder);

        Map<String,Object> map = new HashMap<String, Object>();
        map.put("ret",ret);
        return map;
    }

//    @GetMapping(value = "/materialRecordInfo")
//    public String materialRecordInfo(String inventory_id, HttpSession session)
//    {
//        if (inventory_id!=null)
//        {
//            Map materialInfo = materialStaffService.selectMaterialInventoryInfoById(Integer.valueOf(inventory_id));
//            session.setAttribute("materialInfo",materialInfo);
//            return "admin/staff/material/materialInfo";
//        }
//        return "admin/staff/material/materialInfo";
//    }
}