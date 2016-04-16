package com.web.service;

import com.common.SearchTemplate;
import com.web.dao.CaseDao;
import com.web.dao.PatientDao;
import com.web.entity.CaseManage;
import com.web.entity.Patient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;


/**
 * Created by gaoyang on 16/2/29.
 */
@Service("caseService")
public class CaseService {

    @Autowired
    public CaseDao caseDao ;

    /**
     * 查询
     * @param map
     * @return
     */
    public SearchTemplate searchPatient(Map map){
        return caseDao.searchCase(map);
    }

    public void saveCase(CaseManage caseManage){
        caseDao.save(caseManage);
    }

    public CaseManage getCaseById(int id){
        return (CaseManage) caseDao.getObjectById(id,CaseManage.class);
    }

}