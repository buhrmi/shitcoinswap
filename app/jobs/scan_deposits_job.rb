# Walks the blocks that follow each network's last scanned height and records
# the deposits it finds. Scheduled as a recurring task in config/recurring.yml.
class ScanDepositsJob < ApplicationJob
  def perform
    Network.find_each do |network|
      report = network.scan_deposits

      Rails.logger.info(
        "#{network.name}: scanned blocks #{report[:from]}-#{report[:to]}: " \
        "#{report[:created]} new deposit(s), " \
        "#{report[:refreshed]} pending deposit(s) recounted, " \
        "#{report[:credited]} deposit(s) credited."
      )
    end
  end
end
