import UIKit

class WaitingRoomVC: UIViewController {
    @IBOutlet weak var LeaderLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startGroupQuizButton: UIButton!
    
    var timer: Timer!
    let groupQuizService = GroupQuizService()
    let userPersistence = UserPersistence(coreDataManager: CoreDataManager())
    

    override func viewDidLoad() {
        super.viewDidLoad()
        groupQuizService.groupProgressDelegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 150
        
        groupQuizService.loadGroupStatus(groupId: GroupQuizService.grpId!, courseId: IndividualQuizService.quizCourseId!, quizId: IndividualQuizService.quizId!, sessionId: IndividualQuizService.quizSessionId!)
        repeatGroupProgressNetworkCall()
        startGroupQuizButton.isHidden = true
        startGroupQuizButton.isEnabled = false
        
        //update User Status
        var updateUserStatusResult = userPersistence.updateUserStatus(with: LoginService.userId!, with: "inWaitingRoom")
        Log.info(updateUserStatusResult)
        updateUserStatusResult = userPersistence.updateUserGroupId(with: LoginService.userId!, with: GroupQuizService.grpId!)
    }
    
    func repeatGroupProgressNetworkCall(){
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(WaitingRoomVC.groupProgressCall), userInfo: nil, repeats: false)
    }
    
    
    @objc func groupProgressCall(){
        if GroupQuizService.groupLeaderStatus?.userId == LoginService.userId!{
            let updateUserStatusResult = userPersistence.updateUserStatusIfIsLeader(with: LoginService.userId!, with: true)
            Log.info(updateUserStatusResult)
        }
        //get groupStatus
        groupQuizService.loadGroupStatus(groupId: GroupQuizService.grpId!, courseId: IndividualQuizService.quizCourseId!, quizId: IndividualQuizService.quizId!, sessionId: IndividualQuizService.quizSessionId!)
    }
    @IBAction func startGroupQuizButtonTapped(_ sender: UIButton) {
        if(LoginService.userId! == GroupQuizService.groupLeaderStatus?.userId){
            timer.invalidate()
            let updateUserStatusResult = userPersistence.updateUserStatus(with: LoginService.userId!, with: "inGroupQuiz")
            _ = userPersistence.updateUserStatusIfIsLeader(with: LoginService.userId!, with: true)
            Log.info(updateUserStatusResult)

            performSegue(withIdentifier: "groupQuizSegue", sender: self)
        }else{
            _ = userPersistence.updateUserStatusIfIsLeader(with: LoginService.userId!, with: false)
            let updateUserStatusResult = userPersistence.updateUserStatus(with: LoginService.userId!, with: "inGroupQuiz")
            
            Log.info(updateUserStatusResult)

            timer.invalidate()
            performSegue(withIdentifier: "testSegue", sender: self)
        }
    }
    
}

extension WaitingRoomVC: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupQuizService.groupMemberStatus.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupMemberStatusCell", for: indexPath) as? GroupProgressTVCellTableViewCell else {
            return UITableViewCell()
        }
        if GroupQuizService.groupMemberStatus.count == 0 {
            return UITableViewCell()
        } else {
            cell.decorate(with: GroupQuizService.groupMemberStatus[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}


extension WaitingRoomVC: GroupProgressDelegate{
    func updateLabel() {
        let countMembersInCompleteQuiz = GroupQuizService.groupMemberStatus.filter({$0.status != "complete"})
        if countMembersInCompleteQuiz.count > 0{
            self.tableView.reloadData()
            guard let _ = GroupQuizService.groupLeaderStatus else{
                self.LeaderLabel.text = ""
                return
            }
            self.LeaderLabel.text = GroupQuizService.groupLeaderStatus?.userId
            self.repeatGroupProgressNetworkCall()
        }else{
            self.tableView.reloadData()
            self.LeaderLabel.text = GroupQuizService.groupLeaderStatus?.userId
            
            self.startGroupQuizButton.isHidden = false
            if(LoginService.userId! == GroupQuizService.groupLeaderStatus?.userId){
                self.startGroupQuizButton.isEnabled = true
            }else{
                self.startGroupQuizButton.setTitle("GroupQuizProgress ", for: .normal)
                self.startGroupQuizButton.isEnabled = true
            }
        }

    }
}
