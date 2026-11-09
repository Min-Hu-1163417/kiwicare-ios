//
//  InvoiceRepository.swift
//  KiwiCare
//
//  Created by Vincent Hu on 07/11/2026.
//

protocol InvoiceRepository {
    /// 保存到本地，状态为 pending，不会访问网络
    func save(_ invoice: Invoice) throws

    /// 当前用户的所有发票，按创建时间倒序
    func invoices(for userID: String) throws -> [Invoice]

    /// 把所有待上传的发票上传到服务器
    func syncPending() async

    /// 本地的发票有变化时（新建、同步状态改变）发出一个事件。
    /// 每次调用返回一个新的流，可以有多个观察者
    func changes() -> AsyncStream<Void>
}
