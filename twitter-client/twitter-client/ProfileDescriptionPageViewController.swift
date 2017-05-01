//
//  ProfileDescriptionPageViewController.swift
//  Twitter
//
//  Created by Alexander Svetlichny & Grigory Setezhev in 2017
//  Copyright © 2017 CS333. All rights reserved.
//

import UIKit

final class ProfileDescriptionPageViewController: UIPageViewController {

    // MARK: - Properties

    // MARK: Private Properties
    fileprivate(set) lazy var orderedViewControllers: [UIViewController] = {
        return [
            self.newPageViewController("Left"),
            self.newPageViewController("Right")
        ]
    }()

    fileprivate func newPageViewController(_ side: String) -> UIViewController {
        return AppInfo.storyboard.instantiateViewController(withIdentifier: "ProfilePage\(side)VC")
    }

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        dataSource = self

        if let firstViewController = orderedViewControllers.first {
            setViewControllers( [firstViewController],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }

        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.lightGray
        appearance.currentPageIndicatorTintColor = UIColor.gray
    }

}

// MARK: - UIPageViewControllerDataSource
extension ProfileDescriptionPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }

        return firstViewControllerIndex
    }

}
