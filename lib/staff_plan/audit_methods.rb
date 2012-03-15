module StaffPlan::AuditMethods
  def update_originator_timestamp
    terminator = self.versions.last.try(:terminator)
    User.find_by_id(terminator.to_i).update_timestamp! if terminator.present?
  end
end
